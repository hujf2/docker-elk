FROM arm64v8/debian:stretch

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

COPY ./config/sources.list /etc/apt/sources.list
# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.11
# downloaded from https://github.com/tianon/gosu/releases
COPY ./gosu-arm64 /usr/local/bin/gosu
COPY ./gosu-arm64.asc /usr/local/bin/gosu.asc

RUN set -eux \
	&& apt-get update \
	&& dpkg-reconfigure -f noninteractive tzdata \
	&& rm -rf /etc/localtime && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
	&& echo "Asia/Shanghai" > /etc/timezone \
	# gpg: not found - https://github.com/nodejs/docker-node/issues/980
	&& apt-get install -y --no-install-recommends ca-certificates curl unzip gnupg gnupg2 dirmngr \
	&& rm -rf /var/lib/apt/lists/* \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true
	
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
	
ENV ZOO_CONF_DIR=/conf \
    ZOO_DATA_DIR=/data \
    ZOO_DATA_LOG_DIR=/datalog \
    ZOO_LOG_DIR=/logs \
    ZOO_TICK_TIME=2000 \
    ZOO_INIT_LIMIT=5 \
    ZOO_SYNC_LIMIT=2 \
    ZOO_AUTOPURGE_PURGEINTERVAL=0 \
    ZOO_AUTOPURGE_SNAPRETAINCOUNT=3 \
    ZOO_MAX_CLIENT_CNXNS=60 \
    ZOO_STANDALONE_ENABLED=true \
    ZOO_ADMINSERVER_ENABLED=true

# Add a user with an explicit UID/GID and create necessary directories
RUN set -eux; \
    groupadd -r zookeeper --gid=1000; \
    useradd -r -g zookeeper --uid=1000 zookeeper; \
    mkdir -p "$ZOO_DATA_LOG_DIR" "$ZOO_DATA_DIR" "$ZOO_CONF_DIR" "$ZOO_LOG_DIR"; \
    chown zookeeper:zookeeper "$ZOO_DATA_LOG_DIR" "$ZOO_DATA_DIR" "$ZOO_CONF_DIR" "$ZOO_LOG_DIR"

ARG GPG_KEY=BBE7232D7991050B54C8EA0ADC08637CA615D22C
ARG SHORT_DISTRO_NAME=zookeeper-3.5.6
ARG DISTRO_NAME=apache-zookeeper-3.5.6-bin

COPY $DISTRO_NAME.tar.gz /tmp/
COPY $DISTRO_NAME.tar.gz.asc /tmp/
# Download Apache Zookeeper, verify its PGP signature, untar and clean up
RUN set -eux; \
    # wget -q "https://www.apache.org/dist/zookeeper/$SHORT_DISTRO_NAME/$DISTRO_NAME.tar.gz"; \
    # wget -q "https://www.apache.org/dist/zookeeper/$SHORT_DISTRO_NAME/$DISTRO_NAME.tar.gz.asc"; \
    export GNUPGHOME="$(mktemp -d)"; \
	mv /tmp/$DISTRO_NAME.tar.gz .; \
	mv /tmp/$DISTRO_NAME.tar.gz.asc .; \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-key "$GPG_KEY" || \
    gpg --keyserver pgp.mit.edu --recv-keys "$GPG_KEY" || \
    gpg --keyserver keyserver.pgp.com --recv-keys "$GPG_KEY"; \
    gpg --batch --verify "$DISTRO_NAME.tar.gz.asc" "$DISTRO_NAME.tar.gz"; \
    tar -zxf "$DISTRO_NAME.tar.gz"; \
    mv "$DISTRO_NAME/conf/"* "$ZOO_CONF_DIR"; \
    rm -rf "$GNUPGHOME" "$DISTRO_NAME.tar.gz" "$DISTRO_NAME.tar.gz.asc"; \
    chown -R zookeeper:zookeeper "/$DISTRO_NAME"

WORKDIR $DISTRO_NAME
VOLUME ["$ZOO_DATA_DIR", "$ZOO_DATA_LOG_DIR", "$ZOO_LOG_DIR"]

EXPOSE 2181 2888 3888 8080

ENV PATH=$PATH:/$DISTRO_NAME/bin \
    ZOOCFGDIR=$ZOO_CONF_DIR

COPY docker-entrypoint.sh /
RUN chown zookeeper:zookeeper /docker-entrypoint.sh && \
    chmod +x /docker-entrypoint.sh
	
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["zkServer.sh", "start-foreground"]

## ****************************** 参考资料 *****************************************
## 制作Docker Image: docker build -t elk/zookeeper-3.5.6:arm64v8 .
##
## https://github.com/31z4/zookeeper-docker