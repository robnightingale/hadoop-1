from master.cloud.com:5000/base
MAINTAINER Sumit Kumar Maji

ARG REPOSITORY_HOST
WORKDIR /tmp

RUN wget "$REPOSITORY_HOST"/jdk-8u131-linux-x64.tar.gz \
&& tar -xf jdk-8u131-linux-x64.tar.gz -C /usr/local/ \
&& mv /usr/local/jdk1.8.0_131 /usr/local/jdk \
&& rm -rf jdk-8u131-linux-x64.tar.gz \
&& wget "$REPOSITORY_HOST"/apache-maven-3.3.9-bin.tar.gz \
&& tar -xf apache-maven-3.3.9-bin.tar.gz -C /usr/local/ \
&& mv /usr/local/apache-maven-3.3.9 /usr/local/maven \
&& rm -rf apache-maven-3.3.9-bin.tar.gz \
&& mv /usr/local/maven/conf/settings.xml /usr/local/maven/conf/settings.xml_bk

COPY settings.xml /usr/local/maven/conf/

ENV JAVA_HOME="/usr/local/jdk"
ENV PATH="$PATH:$JAVA_HOME/bin"

ENV MVN_HOME /usr/local/maven
ENV PATH $PATH:$MVN_HOME/bin
ENV MAVEN_OPTS -Xms256m -Xmx512m

RUN java -version
RUN mvn -version

RUN apt-get update \
&& apt-get install -yq zip

#Install g++ for installing protobuf
RUN apt-get upgrade -yq \
&& apt-get install -yq build-essential

RUN gcc -v
RUN make -v

RUN apt-get install -yq g++ make autoconf automake libtool cmake zlib1g-dev pkg-config libssl-dev

#Only protoc version 2.5.0 is used for compilation
RUN wget --no-check-certificate https://github.com/google/protobuf/releases/download/v2.5.0/protobuf-2.5.0.tar.gz \
&& tar -xf protobuf-2.5.0.tar.gz \
&& cd protobuf-2.5.0 \
&& ./configure \
&& make \
&& make install

RUN wget http://redrockdigimark.com/apachemirror/hadoop/common/hadoop-3.1.0/hadoop-3.1.0-src.tar.gz \
&& tar -xzvf hadoop-3.1.0-src.tar.gz \
&& rm -rf hadoop-3.1.0-src.tar.gz

ENV LD_LIBRARY_PATH /usr/local/lib:$LD_LIBRARY_PATH
ENV HADOOP_PROTOC_PATH /usr/local/bin/protoc

ADD execute.sh execute.sh
RUN chmod +x execute.sh

ENTRYPOINT ["/tmp/execute.sh"]
