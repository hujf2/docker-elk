FROM arm64v8/debian:stretch

################
# dependencies #
################
COPY ./config/sources.list /etc/apt/sources.list

# add our user and group first to make sure their IDs get assigned consistently
RUN groupadd -r logstash && useradd -r -m -g logstash logstash

# downloaded from https://github.com/tianon/gosu/releases
COPY ./gosu-arm64 /usr/local/bin/gosu
COPY ./gosu-arm64.asc /usr/local/bin/gosu.asc

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.11
RUN set -x \
	&& apt-get update \
	&& dpkg-reconfigure -f noninteractive tzdata \
	&& rm -rf /etc/localtime && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
	&& echo "Asia/Shanghai" > /etc/timezone \
	# gpg: not found - https://github.com/nodejs/docker-node/issues/980
	&& apt-get install -y --no-install-recommends ca-certificates curl unzip gnupg gnupg2 dirmngr zip unzip \
	&& rm -rf /var/lib/apt/lists/* \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

ENV JAVA_HOME=/usr/local/openjdk-8
ENV JRE_HOME=${JAVA_HOME}/jre
ENV CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
ENV PATH=${JAVA_HOME}/bin:${ES_HOME}/bin::$PATH

COPY ./jdk-8u231-linux-arm64-vfp-hflt.tar.gz /opt/jdk-8u231.tar.gz
RUN mkdir -p "$JAVA_HOME" \
    && tar --extract \
		   --file /opt/jdk-8u231.tar.gz \
		   --directory "$JAVA_HOME" \
		   --strip-components 1 \
		   --no-same-owner \
	&& javac -version \
	&& java -version
	
# install logstash
ENV LOGSTASH_VERSION=6.8.4
ENV LOGSTASH_HOME=/usr/share/logstash
COPY ./logstash-6.8.4.tar.gz /opt/logstash-6.8.4.tar.gz
RUN set -x && \   
    #&& wget "https://download.elastic.co/logstash/logstash/logstash-$LOGSTASH_VERSION.tar.gz" \
	cd /opt && \
	tar -xvzf /opt/logstash-$LOGSTASH_VERSION.tar.gz && \
	mv /opt/logstash-$LOGSTASH_VERSION "$LOGSTASH_HOME" && \
	rm /opt/logstash-$LOGSTASH_VERSION.tar.gz && \
	chown -R logstash:logstash $LOGSTASH_HOME

# Bug: https://github.com/elastic/logstash/issues/10888
RUN mkdir -p /tmp/jruby-complete && \
    unzip -q /usr/share/logstash/logstash-core/lib/jars/jruby-complete-9.2.7.0.jar -d /tmp/jruby-complete && \
#   echo cp /tmp/jruby-complete/META-INF/jruby.home/lib/ruby/stdlib/ffi/platform/aarch64-linux/{types,platform}.conf && \
    cp /tmp/jruby-complete/META-INF/jruby.home/lib/ruby/stdlib/ffi/platform/aarch64-linux/types.conf \
	   /tmp/jruby-complete/META-INF/jruby.home/lib/ruby/stdlib/ffi/platform/aarch64-linux/platform.conf && \
    cd /tmp/jruby-complete && \
    zip -qr /tmp/jruby-complete-9.2.7.0.jar * && \
    mv -f /tmp/jruby-complete-9.2.7.0.jar /usr/share/logstash/logstash-core/lib/jars/jruby-complete-9.2.7.0.jar && \
	rm -rf /tmp/jruby-complete
	
ENV PATH $LOGSTASH_HOME/bin:$PATH

# necessary for 5.0+ (overriden via "--path.settings", ignored by < 5.0)
ENV LOGSTASH_SETTINGS_DIR /etc/logstash
# comment out some troublesome configuration parameters
#   path.log: logs should go to stdout
#   path.config: No config files found: /etc/logstash/conf.d/*
RUN set -ex \
    && if [ -f "$LOGSTASH_SETTINGS_DIR/logstash.yml" ]; then \
        sed -ri 's!^(path.log|path.config):!#&!g' "$LOGSTASH_SETTINGS_DIR/logstash.yml"; \
    fi

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

EXPOSE 9600 5044
WORKDIR /usr/share/logstash

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["-e", ""]
## ****************************** 参考资料 *****************************************
## 制作Docker Image: docker build -t elk/logstash-6.8.4:arm64v8 .