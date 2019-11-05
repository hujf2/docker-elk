FROM arm64v8/debian:stretch

MAINTAINER Ryan C Koch <ryanckoch@gmail.com>

COPY ./config/sources.list /etc/apt/sources.list
RUN apt-get update && \
    apt-get install -y git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
	
COPY ./jdk-8u231-linux-arm64-vfp-hflt.tar.gz /opt/jdk-8u231.tar.gz

ENV JAVA_HOME=/usr/local/openjdk-8
ENV JRE_HOME=${JAVA_HOME}/jre
ENV CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
ENV PATH=${JAVA_HOME}/bin:${ES_HOME}/bin::$PATH
	
RUN mkdir -p "$JAVA_HOME" \
    && tar --extract \
		   --file /opt/jdk-8u231.tar.gz \
		   --directory "$JAVA_HOME" \
		   --strip-components 1 \
		   --no-same-owner \
	&& javac -version \
	&& java -version

ENV ZK_HOSTS=localhost:2181 \
    KM_VERSION=2.0.0.2 \
    KM_CONFIGFILE="conf/application.conf"

# curl -L https://github.com/yahoo/kafka-manager/archive/$KM_VERSION.tar.gz -o /tmp/kafka-manager.tar.gz && \
COPY kafka-manager-$KM_VERSION.tar.gz /tmp/kafka-manager.tar.gz
COPY sbt-launch-1.2.8.jar /root/.sbt/launchers/1.2.8/sbt-launch.jar
COPY repositories /root/.sbt/repositories
RUN tar -xvzf /tmp/kafka-manager.tar.gz -C /tmp && \
    mv /tmp/kafka-manager-$KM_VERSION /tmp/kafka-manager && \
    cd /tmp/kafka-manager && \
    echo 'scalacOptions ++= Seq("-Xmax-classfile-name", "200")' >> build.sbt && \
    ./sbt clean dist && \
    mkdir -p /opt && \
    unzip  -d /opt ./target/universal/kafka-manager-${KM_VERSION}.zip && \
    mv /opt/kafka-manager-$KM_VERSION /opt/kafka-manager && \
    rm -fr /tmp/* /root/.sbt /root/.ivy2 && \
    printf '#!/bin/sh\nexec ./bin/kafka-manager -Dconfig.file=${KM_CONFIGFILE} "${KM_ARGS}" "${@}"\n' > /opt/kafka-manager/km.sh && \
    chmod +x /opt/kafka-manager/km.sh

WORKDIR /opt/kafka-manager

EXPOSE 9000
ENTRYPOINT ["./km.sh"]

## ****************************** 参考资料 *****************************************
## 制作Docker Image: docker build -t elk/kafka-manager-2.0.0.2:arm64v8 .
# https://github.com/StratoSpire/kafka-manager-docker
# https://github.com/hleb-albau/kafka-manager-docker
# https://github.com/deric/kafka-manager-docker
# https://github.com/PaladinTyrion/docker-kafka-eagle