FROM sumit/maven:latest
MAINTAINER Sumit Kumar Maji

RUN apt-get update
RUN apt-get install -yq gcc make
RUN apt-get install -yq g++
RUN apt-get install -yq build-essential
RUN apt-get install -yq zip
RUN apt-get install -yq g++ autoconf automake libtool cmake zlib1g-dev pkg-config libssl-dev


WORKDIR /tmp/
ARG REPOSITORY_HOST
RUN wget http://www-eu.apache.org/dist/commons/daemon/source/commons-daemon-1.0.15-src.tar.gz &&\
tar -xzvf commons-daemon-1.0.15-src.tar.gz

RUN cd commons-daemon-1.0.15-src/src/native/unix &&\
export CFLAGS=-m64 &&\
export LDFLAGS=-m64 &&\
./configure --with-java=/usr/local/jdk &&\
make &&\
mv ./jsvc  /usr/bin/jsvc &&\
which jsvc &&\
jsvc -help

RUN wget "$REPOSITORY_HOST"/repo/jce_policy-8.zip
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

RUN wget "$REPOSITORY_HOST"/repo/hadoop-2.6.5.tar.gz &&\
tar -xzvf hadoop-2.6.5.tar.gz &&\
mv /usr/local/hadoop-2.6.5 /usr/local/hadoop &&\
rm -rf /usr/local/hadoop-2.6.5.tar.gz &&\
java -version

RUN sed -i 's/\(export JAVA_HOME=${JAVA_HOME}\)/#\1/' /usr/local/hadoop/etc/hadoop/hadoop-env.sh &&\
sed -i '/export JAVA_HOME/ a\\nexport JAVA_HOME=/usr/local/jdk' /usr/local/hadoop/etc/hadoop/hadoop-env.sh &&\
mkdir -p /app/hadoop/tmp &&\
mkdir -p /usr/local/hadoop_store/hdfs/namenode &&\
mkdir -p /usr/local/hadoop_store/hdfs/datanode
ADD config/hdfs-site.xml /usr/local/hadoop/etc/hadoop/hdfs-site.xml
ADD config/mapred-site.xml /usr/local/hadoop/etc/hadoop/mapred-site.xml
ADD config/core-site.xml /usr/local/hadoop/etc/hadoop/core-site.xml
ADD config/httpfs-site.xml /usr/local/hadoop/etc/hadoop/httpfs-site.xml
ADD config/yarn-site.xml /usr/local/hadoop/etc/hadoop/yarn-site.xml 
ADD config/slaves /usr/local/hadoop/etc/hadoop/slaves

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

RUN addgroup hadoop
# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000 54310

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
RUN chown root:root /utility

#CMD ["/etc/bootstrap.sh", "-ssh"]
#CMD /usr/sbin/sshd -D
ENTRYPOINT ["/utility/hadoop/bootstrap.sh"]
