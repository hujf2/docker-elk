FROM arm64v8/debian:stretch

MAINTAINER Ches Martin <ches@whiskeyandgrits.net>

# The Scala 2.11 build is currently recommended by the project.
ENV KAFKA_VERSION=2.3.1 KAFKA_SCALA_VERSION=2.11 JMX_PORT=7203
ENV KAFKA_RELEASE_ARCHIVE kafka_${KAFKA_SCALA_VERSION}-${KAFKA_VERSION}.tgz

COPY ./config/sources.list /etc/apt/sources.list
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
	
RUN mkdir /kafka /data /logs

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ca-certificates

# Download Kafka binary distribution
# ADD http://www.us.apache.org/dist/kafka/${KAFKA_VERSION}/${KAFKA_RELEASE_ARCHIVE} /tmp/
# ADD https://dist.apache.org/repos/dist/release/kafka/${KAFKA_VERSION}/${KAFKA_RELEASE_ARCHIVE}.md5 /tmp/
COPY ${KAFKA_RELEASE_ARCHIVE} /tmp/
COPY ${KAFKA_RELEASE_ARCHIVE}.md5 /tmp/

WORKDIR /tmp

# Check artifact digest integrity
#RUN echo VERIFY CHECKSUM: && \
#  gpg --print-md MD5 ${KAFKA_RELEASE_ARCHIVE} 2>/dev/null && \
#  cat ${KAFKA_RELEASE_ARCHIVE}.md5

# Install Kafka to /kafka
COPY kafka/kafka-run-class.sh /tmp/kafka-run-class.sh
RUN tar -zx -C /kafka --strip-components=1 -f ${KAFKA_RELEASE_ARCHIVE} && \
  cp -f /tmp/kafka-run-class.sh /kafka/bin/kafka-run-class.sh  && \
  rm -rf kafka_*

ADD config /kafka/config
ADD docker-entrypoint.sh /docker-entrypoint.sh


# Set up a user to run Kafka
RUN groupadd kafka && \
  useradd -d /kafka -g kafka -s /bin/false kafka && \
  chown -R kafka:kafka /kafka /data /logs && \
  chown kafka:kafka /docker-entrypoint.sh && \
  chmod +x /docker-entrypoint.sh
	
USER kafka
ENV PATH /kafka/bin:$PATH
WORKDIR /kafka

# broker, jmx
EXPOSE 9092 ${JMX_PORT}
VOLUME [ "/data", "/logs" ]

CMD ["/docker-entrypoint.sh"]

## ****************************** 参考资料 *****************************************
## 制作Docker Image: docker build -t elk/kafka-2.3.1:arm64v8 .
## https://github.com/owlab-exp/docker-kafka-arm64