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
RUN apt-get upgrade
RUN apt-get install -yq build-essential

RUN gcc -v
RUN make -v

RUN wget https://github.com/google/protobuf/archive/v3.6.0.tar.gz \
&& tar -xf v3.6.0.tar.gz
