FROM master.cloud.com:5000/ldapclient
MAINTAINER Sumit Kumar Maji

ARG REPOSITORY_HOST
ARG HADOOP_VERSION

WORKDIR /tmp

RUN wget "$REPOSITORY_HOST"/jdk-8u131-linux-x64.tar.gz \
&& tar -xf jdk-8u131-linux-x64.tar.gz -C /usr/local/ \
&& mv /usr/local/jdk1.8.0_131 /usr/local/jdk \
&& rm -rf jdk-8u131-linux-x64.tar.gz \
&& wget "$REPOSITORY_HOST"/apache-maven-3.3.9-bin.tar.gz \
&& tar -xf apache-maven-3.3.9-bin.tar.gz -C /usr/local/ \
&& mv /usr/local/apache-maven-3.3.9 /usr/local/maven \
&& rm -rf apache-maven-3.3.9-bin.tar.gz
#&& mv /usr/local/maven/conf/settings.xml /usr/local/maven/conf/settings.xml_bk

#COPY settings.xml /usr/local/maven/conf/

ENV JAVA_HOME="/usr/local/jdk"
ENV PATH="$PATH:$JAVA_HOME/bin"

ENV MVN_HOME /usr/local/maven
ENV PATH $PATH:$MVN_HOME/bin
ENV MAVEN_OPTS -Xms256m -Xmx512m

RUN java -version
RUN mvn -version

RUN apt-get update
RUN apt-get install -yq gcc make
RUN apt-get install -yq g++
RUN apt-get install -yq build-essential
RUN apt-get install -yq zip
RUN apt-get install -yq g++ autoconf automake libtool cmake zlib1g-dev pkg-config libssl-dev


#WORKDIR /tmp/
RUN wget "$REPOSITORY_HOST"/commons-daemon-1.1.0-src.tar.gz &&\
tar -xzvf commons-daemon-1.1.0-src.tar.gz

RUN cd commons-daemon-1.1.0-src/src/native/unix &&\
export CFLAGS=-m64 &&\
export LDFLAGS=-m64 &&\
./configure --with-java=/usr/local/jdk &&\
make &&\
mv ./jsvc  /usr/bin/jsvc &&\
which jsvc &&\
jsvc -help

RUN wget "$REPOSITORY_HOST"/jce_policy-8.zip
RUN unzip jce_policy-8.zip
RUN cp UnlimitedJCEPolicyJDK8/local_policy.jar UnlimitedJCEPolicyJDK8/US_export_policy.jar $JAVA_HOME/jre/lib/security

# fetch hadoop source code to build some binaries natively
# for this, protobuf is needed
#RUN curl -L -k https://github.com/google/protobuf/releases/download/v2.5.0/protobuf-2.5.0.tar.gz | tar -xz -C /tmp/

WORKDIR /usr/local/
ARG REPOSITORY_HOST


ENV JAVA_HOME /usr/local/jdk
ENV PATH $JAVA_HOME/bin:$PATH
ENV HADOOP_INSTALL /usr/local/hadoop
ENV PATH $PATH:$HADOOP_INSTALL/bin
ENV PATH $PATH:$HADOOP_INSTALL/sbin
ENV HADOOP_MAPRED_HOME $HADOOP_INSTALL
ENV HADOOP_COMMON_HOME $HADOOP_INSTALL
ENV HADOOP_HDFS_HOME $HADOOP_INSTALL
ENV YARN_HOME $HADOOP_INSTALL
ENV HADOOP_COMMON_LIB_NATIVE_DIR $HADOOP_INSTALL/lib/native
ENV HADOOP_OPTS "-Djava.library.path=$HADOOP_INSTALL/lib/native"
ENV HADOOP_CONF_DIR /usr/local/hadoop/etc/hadoop
ENV JSVC_HOME /usr/bin

RUN wget "$REPOSITORY_HOST"/"$HADOOP_VERSION".tar.gz &&\
tar -xzvf "$HADOOP_VERSION".tar.gz &&\
mv /usr/local/"$HADOOP_VERSION" /usr/local/hadoop &&\
rm -rf /usr/local/"$HADOOP_VERSION".tar.gz &&\
java -version

RUN sed -i 's/\(export JAVA_HOME=${JAVA_HOME}\)/#\1/' /usr/local/hadoop/etc/hadoop/hadoop-env.sh &&\
sed -i '/export JAVA_HOME/ a\\nexport JAVA_HOME=/usr/local/jdk' /usr/local/hadoop/etc/hadoop/hadoop-env.sh &&\
mkdir -p /app/hadoop/tmp &&\
mkdir -p /usr/local/hadoop_store/hdfs/namenode &&\
mkdir -p /usr/local/hadoop_store/hdfs/datanode
RUN mkdir -p /tmp/config/hadoop/certs
ADD config/hdfs-site.xml /tmp/config/hadoop/hdfs-site.xml
ADD config/mapred-site.xml /tmp/config/hadoop/mapred-site.xml
ADD config/core-site.xml /tmp/config/hadoop/core-site.xml
ADD config/httpfs-site.xml /tmp/config/hadoop/httpfs-site.xml
ADD config/yarn-site.xml /tmp/config/hadoop/yarn-site.xml
ADD config/slaves /tmp/config/hadoop/slaves
ADD config/ssl-server.xml /tmp/config/hadoop/ssl-server.xml
ADD config/ssl-client.xml /tmp/config/hadoop/ssl-client.xml
ADD config/hduser.jks /tmp/config/hadoop/hduser.jks
#RUN mkdir /usr/local/hadoop/etc/hadoop/certs
ADD config/certs/* /tmp/config/hadoop/certs/
#RUN chmod 644 /usr/local/hadoop/etc/hadoop/certs/*
#RUN echo 'yarn.nodemanager.linux-container-executor.group=hadoop\nbanned.users=bin\nmin.user.id=500\nallowed.system.users=hduser' > $HADOOP_INSTALL/etc/hadoop/container-executor.cfg
RUN sed -i '/# resolve links/ s/^/export JAVA_HOME=\/usr\/local\/jdk\n/' $HADOOP_INSTALL/sbin/httpfs.sh
#RUN $HADOOP_INSTALL/bin/hdfs namenode -format

#RUN cp /container/bootstrap.sh /etc/bootstrap.sh

# workingaround docker.io build error
RUN ls -la /usr/local/hadoop/etc/hadoop/*-env.sh
RUN chmod +x /usr/local/hadoop/etc/hadoop/*-env.sh
RUN ls -la /usr/local/hadoop/etc/hadoop/*-env.sh

RUN mkdir $HADOOP_INSTALL/input
RUN cp $HADOOP_INSTALL/etc/hadoop/*.xml $HADOOP_INSTALL/input

RUN chown -R root:root $HADOOP_INSTALL

# fetch hadoop source code to build some binaries natively
# for this, protobuf is needed
#RUN curl -L -k https://github.com/google/protobuf/releases/download/v2.5.0/protobuf-2.5.0.tar.gz | tar -xz -C /tmp/
ENV LD_LIBRARY_PATH /usr/local/lib:$HADOOP_INSTALL/lib/native:$LD_LIBRARY_PATH
#RUN cd /tmp/protobuf-2.5.0 \
#    && ./configure \
#    && make \
#    && make install
#ENV HADOOP_PROTOC_PATH /usr/local/bin/protoc

#RUN curl -L http://www.eu.apache.org/dist/hadoop/common/hadoop-2.6.5/hadoop-2.6.5-src.tar.gz | tar -xz -C /tmp

# build native hadoop-common libs to remove warnings because of 64 bit OS
#RUN rm -rf $HADOOP_INSTALL/lib/native
#RUN cd /tmp/hadoop-2.6.5-src/hadoop-common-project/hadoop-common \
#    && mvn compile -Pnative \
#    && cp target/native/target/usr/local/lib/libhadoop.a $HADOOP_INSTALL/lib/native \
#    && cp target/native/target/usr/local/lib/libhadoop.so.1.0.0 $HADOOP_INSTALL/lib/native
# build container-executor binary
#RUN cd /tmp/hadoop-2.6.5-src/hadoop-yarn-project/hadoop-yarn/hadoop-yarn-server/hadoop-yarn-server-nodemanager \
#    && mvn compile -Pnative \
#    && cp target/native/target/usr/local/bin/container-executor $HADOOP_INSTALL/bin/ \
#    && chmod 6050 $HADOOP_INSTALL/bin/container-executor

RUN mkdir -p /usr/lib/bigtop-utils/
RUN cp /usr/bin/jsvc /usr/lib/bigtop-utils/
#RUN sed -i "s/\${HADOOP_SECURE_DN_USER}/hduser/g" /usr/local/hadoop/etc/hadoop/hadoop-env.sh &&\
#sed -i "/HADOOP_SECURE_DN_PID_DIR/ s/\${HADOOP_PID_DIR}/\/var\/run\/hadoop\/\$HADOOP_SECURE_DN_USER/g" /usr/local/hadoop/etc/hadoop/hadoop-env.sh &&\
#sed -i "s/\${HADOOP_LOG_DIR}\/\${HADOOP_HDFS_USER}/\/var\/log\/hadoop\/\$HADOOP_SECURE_DN_USER/g" /usr/local/hadoop/etc/hadoop/hadoop-env.sh &&\
#echo 'export JSVC_HOME=/usr/lib/bigtop-utils/' >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh


RUN mkdir -p /var/log/hadoop
RUN mkdir -p /var/run/hadoop
RUN addgroup hadoop

RUN dd if=/dev/urandom of=/etc/security/http_secret bs=1024 count=1
RUN chown root:hadoop /etc/security/http_secret
RUN chmod 440 /etc/security/http_secret




# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000 54310 1006 10019

#Hdfs SSL port
EXPOSE 50470 50475

# httpfs port
EXPOSE 14000

# Mapred ports
EXPOSE 10020 19888 10033 54311

#Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088 8025 8039
#Other ports
EXPOSE 49707 22 2122

#Client-Port Range
EXPOSE 56000-56020
RUN mkdir -p /utility/hadoop
ADD utility/bootstrap.sh /utility/hadoop/bootstrap.sh
RUN chmod +x /utility/hadoop/bootstrap.sh
ADD utility/kerberizeNamenode.sh /utility/hadoop/kerberizeNamenode.sh
RUN chmod +x /utility/hadoop/kerberizeNamenode.sh
ADD utility/kerberizeDatanode.sh /utility/hadoop/kerberizeDatanode.sh
RUN chmod +x /utility/hadoop/kerberizeDatanode.sh
ADD utility/kerberizeYarn.sh /utility/hadoop/kerberizeYarn.sh
RUN chmod +x /utility/hadoop/kerberizeYarn.sh
ADD utility/kerberizeSecondarynode.sh /utility/hadoop/kerberizeSecondarynode.sh
RUN chmod +x /utility/hadoop/kerberizeSecondarynode.sh
ADD utility/enableSSL.sh /utility/hadoop/enableSSL.sh
RUN chmod +x /utility/hadoop/enableSSL.sh
ADD utility/kerberizeHttpfs.sh /utility/hadoop/kerberizeHttpfs.sh
RUN chmod +x /utility/hadoop/kerberizeHttpfs.sh

RUN chown root:root /utility



RUN mkdir -p /configg/hadoop
ADD config/config /configg/hadoop/config
#CMD ["/etc/bootstrap.sh", "-ssh"]
#CMD /usr/sbin/sshd -D
#ENTRYPOINT ["/utility/hadoop/bootstrap.sh"]
