FROM sumit/base-trusty
MAINTAINER Sumit Kumar Maji

RUN apt-get update
RUN apt-get install -y software-properties-common
RUN apt-add-repository -y ppa:webupd8team/java
RUN apt-get update
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get install -y oracle-java8-installer


WORKDIR /usr/local/
ARG REPOSITORY_HOST

#ENV JAVA_HOME /usr/local/jdk
#ENV PATH $JAVA_HOME/bin:$PATH
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

COPY core-site.xml hdfs-site.xml  slaves bootstrap.sh httpfs-site.xml ssh_config mapred-site.xml setup.sh yarn-site.xml /container/

RUN /container/setup.sh

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

#CMD ["/etc/bootstrap.sh", "-ssh"]
CMD /usr/sbin/sshd -D
