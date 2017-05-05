FROM sumit/jdk1.7:latest
MAINTAINER Sumit Kumar Maji

RUN apt-get update 
RUN apt-get install -yq openssh-server
RUN apt-get install -yq openssh-client

RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# passwordless ssh
RUN ssh-keygen -qy -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -qy -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN mkdir /root/.ssh
RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

ADD ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/config
RUN chown root:root /root/.ssh/config

# fix the 254 error code
RUN sed  -i "/^[^#]*UsePAM/ s/.*/#&/"  /etc/ssh/sshd_config
RUN echo "UsePAM no" >> /etc/ssh/sshd_config
RUN echo "Port 2122" >> /etc/ssh/sshd_config

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

RUN addgroup hadoop
RUN adduser --ingroup hadoop hduser
RUN adduser hduser sudo

RUN su - hduser -c "ssh-keygen -t rsa -P \"\" -f /home/hduser/.ssh/id_rsa"
RUN su - hduser -c "cp /home/hduser/.ssh/id_rsa.pub /home/hduser/.ssh/authorized_keys"

ADD ssh_config /home/hduser/.ssh/config
RUN chmod 600 /home/hduser/.ssh/config
RUN chown hduser:hadoop /home/hduser/.ssh/config

RUN echo 'hduser:hadoop' | chpasswd


#Install Hadoop
COPY hadoop-2.5.2.tar.gz /usr/local/hadoop-2.5.2.tar.gz
RUN tar -xzvf /usr/local/hadoop-2.5.2.tar.gz -C /usr/local/
RUN mv /usr/local/hadoop-2.5.2 /usr/local/hadoop
RUN rm -rf /usr/local/hadoop-2.5.2.tar.gz
RUN chown -R hduser:hadoop /usr/local/hadoop

#Java Environemtn Setup
ENV JAVA_HOME /usr/local/jdk1.7
ENV PATH $JAVA_HOME/bin:$PATH
ENV HADOOP_INSTALL /usr/local/hadoop
ENV PATH $PATH:$HADOOP_INSTALL/bin
ENV PATH $PATH:$HADOOP_INSTALL/sbin
ENV HADOOP_MAPRED_HOME $HADOOP_INSTALL
ENV HADOOP_COMMON_HOME $HADOOP_INSTALL
ENV HADOOP_HDFS_HOME $HADOOP_INSTALL
ENV YARN_HOME $HADOOP_INSTALL
ENV HADOOP_COMMON_LIB_NATIVE_DIR $HADOOP_INSTALL/lib/native
ENV HADOOP_OPTS "-Djava.library.path=$HADOOP_INSTALL/lib"
ENV HADOOP_CONF_DIR /usr/local/hadoop/etc/hadoop

RUN su - hduser -c "echo 'export JAVA_HOME=/usr/local/jdk1.7' >> /home/hduser/.bashrc"
RUN su - hduser -c "echo 'export PATH=$PATH:$JAVA_HOME/bin' >> /home/hduser/.bashrc"
RUN su - hduser -c "echo 'export HADOOP_INSTALL=/usr/local/hadoop' >> /home/hduser/.bashrc"
RUN su - hduser -c "echo 'export PATH=$PATH:$HADOOP_INSTALL/bin' >> /home/hduser/.bashrc"
RUN su - hduser -c "echo 'export PATH=$PATH:$HADOOP_INSTALL/sbin' >> /home/hduser/.bashrc"
RUN su - hduser -c "echo 'export HADOOP_MAPRED_HOME=$HADOOP_INSTALL' >> /home/hduser/.bashrc"
RUN su - hduser -c "echo 'export HADOOP_COMMON_HOME=$HADOOP_INSTALL' >> /home/hduser/.bashrc"
RUN su - hduser -c "echo 'export HADOOP_HDFS_HOME=$HADOOP_INSTALL' >> /home/hduser/.bashrc"
RUN su - hduser -c "echo 'export YARN_HOME=$HADOOP_INSTALL' >> /home/hduser/.bashrc"
RUN su - hduser -c "echo 'export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_INSTALL/lib/native' >> /home/hduser/.bashrc"
RUN su - hduser -c "echo 'export HADOOP_OPTS=\"-Djava.library.path=$HADOOP_INSTALL/lib\"' >> /home/hduser/.bashrc"
RUN su - hduser -c "echo 'export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop' >> /home/hduser/.bashrc"
RUN su - hduser -c "echo 'cd /usr/local/hadoop' >> /home/hduser/.bashrc"

RUN java -version

RUN sed -i 's/\(export JAVA_HOME=${JAVA_HOME}\)/#\1/' /usr/local/hadoop/etc/hadoop/hadoop-env.sh
RUN sed -i '/export JAVA_HOME/ a\\nexport JAVA_HOME=/usr/local/jdk1.7' /usr/local/hadoop/etc/hadoop/hadoop-env.sh
RUN chown hduser:hadoop /usr/local/hadoop/etc/hadoop/hadoop-env.sh

RUN mkdir -p /app/hadoop/tmp
RUN chown hduser:hadoop /app/hadoop/tmp

RUN mkdir -p /usr/local/hadoop_store/hdfs/namenode
RUN mkdir -p /usr/local/hadoop_store/hdfs/datanode
RUN chown -R hduser:hadoop /usr/local/hadoop_store

ADD hdfs-site.xml /usr/local/hadoop/etc/hadoop/hdfs-site.xml
ADD mapred-site.xml /usr/local/hadoop/etc/hadoop/mapred-site.xml
ADD core-site.xml /usr/local/hadoop/etc/hadoop/core-site.xml
ADD httpfs-site.xml /usr/local/hadoop/etc/hadoop/httpfs-site.xml
ADD yarn-site.xml /usr/local/hadoop/etc/hadoop/yarn-site.xml
ADD slaves /usr/local/hadoop/etc/hadoop/slaves
RUN chown hduser:hadoop /usr/local/hadoop/etc/hadoop/hdfs-site.xml /usr/local/hadoop/etc/hadoop/mapred-site.xml /usr/local/hadoop/etc/hadoop/core-site.xml /usr/local/hadoop/etc/hadoop/slaves /usr/local/hadoop/etc/hadoop/httpfs-site.xml /usr/local/hadoop/etc/hadoop/yarn-site.xml

#RUN mkdir -p /tmp/native
#RUN curl -L https://github.com/sequenceiq/docker-hadoop-build/releases/download/v2.7.1/hadoop-native-64-2.7.1.tgz | tar -xz -C /tmp/native
#RUN chown -R hduser:hadoop /tmp/native

RUN su - hduser -c "$HADOOP_INSTALL/bin/hdfs namenode -format"

# fixing the libhadoop.so like a boss
#RUN rm -rf /usr/local/hadoop/lib/native
#RUN mv /tmp/native /usr/local/hadoop/lib

#ADD ssh_config /home/hduser/.ssh/config
#RUN chmod 600 /home/hduser/.ssh/config
#RUN chown hduser:hadoop /home/hduser/.ssh/config

ADD bootstrap.sh /etc/bootstrap.sh
RUN chown hduser:hadoop /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh


ENV BOOTSTRAP /etc/bootstrap.sh
RUN su - hduser -c "echo 'export BOOTSTRAP=/etc/bootstrap.sh' >> /home/hduser/.bashrc"

# workingaround docker.io build error
RUN ls -la /usr/local/hadoop/etc/hadoop/*-env.sh
RUN chmod +x /usr/local/hadoop/etc/hadoop/*-env.sh
RUN ls -la /usr/local/hadoop/etc/hadoop/*-env.sh

RUN mkdir $HADOOP_INSTALL/input
RUN cp $HADOOP_INSTALL/etc/hadoop/*.xml $HADOOP_INSTALL/input
RUN chown hduser:hadoop $HADOOP_INSTALL/input
#CMD ["/etc/bootstrap.sh", "-d"]
#CMD ["/etc/bootstrap.sh", "-bash"]
# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000 54310

# httpfs port
EXPOSE 14000

# Mapred ports
EXPOSE 10020 19888 10033 54311

#Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088 8025
#Other ports
EXPOSE 49707 22 2122

#Client-Port Range
EXPOSE 56000-56020

#CMD ["/etc/bootstrap.sh", "-ssh"]
RUN apt-get update && apt-get install -y net-tools
RUN apt-get install -y iputils-ping
CMD /usr/sbin/sshd -D
