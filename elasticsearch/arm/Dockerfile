FROM arm64v8/debian:stretch

################
# dependencies #
################
COPY ./conf/sources.list /etc/apt/sources.list
# downloaded from https://www.elastic.co/cn/downloads/past-releases/elasticsearch-6-8-3
COPY ./elasticsearch-6.8.4.tar.gz /opt/elasticsearch.tar.gz
# downloaded from https://github.com/medcl/elasticsearch-analysis-ik/releases
COPY elasticsearch-analysis-ik-6.8.4.zip /opt/elasticsearch-analysis-ik.zip
COPY ./jdk-8u231-linux-arm64-vfp-hflt.tar.gz /opt/jdk-8u231.tar.gz
# downloaded from https://github.com/tianon/gosu/releases
COPY ./gosu-arm64 /usr/local/bin/gosu
COPY ./gosu-arm64.asc /usr/local/bin/gosu.asc

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.11
# downloaded from https://github.com/tianon/gosu/releases
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

ENV ES_VERSION=6.8.4
ENV ES_HOME=/usr/share/elasticsearch
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

RUN mkdir -p "$ES_HOME" \
	&& tar --extract \
		   --file /opt/elasticsearch.tar.gz \
		   --directory "$ES_HOME" \
		   --strip-components 1 \
		   --no-same-owner \
	&& unzip /opt/elasticsearch-analysis-ik.zip -d /usr/share/elasticsearch/plugins/ik \
	&& groupadd -r elasticsearch \
	&& useradd -r -m -g elasticsearch elasticsearch \	
	&& cd "$ES_HOME" \
    && for path in \
                   ./data \
                   ./data/nodes \
                   ./logs \
                   ./config \
                   ./config/scripts \
                   ./plugins \
       ; do \
            mkdir -p "$path"; \
            chown -R elasticsearch:elasticsearch "$path"; \
            chmod -R o+w "$path"; \
       done \
#    && sysctl -w vm.max_map_count=262144 \
#    && sysctl -p \
#    && sysctl -a | grep "vm.max_map_count" \
    && echo 'hard nofile 65536' >> /etc/security/limits.conf \
    && echo 'soft nofile 65536' >> /etc/security/limits.conf
	
COPY ./conf/elasticsearch.yml /usr/share/elasticsearch/config
COPY ./conf/logging.yml /usr/share/elasticsearch/config

WORKDIR /usr/share/elasticsearch
VOLUME /usr/share/elasticsearch/data
EXPOSE 9200 9300

COPY docker-entrypoint.sh /
RUN chmod -R au+wrx /usr/share/elasticsearch && \
    chown -R elasticsearch:elasticsearch /usr/share/elasticsearch && \
    chown elasticsearch:elasticsearch /docker-entrypoint.sh && \
    chmod +x /docker-entrypoint.sh
	
USER elasticsearch

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["elasticsearch"]

## ****************************** 参考资料 *****************************************
## 制作Docker Image: docker build -t elk/elasticsearch-6.8.4:arm64v8 .
## docker run -itd \
## --restart=always \
## -p 9200:9200 \
## -p 9300:9300 \
## --hostname=elasticsearch-5.6.3-arm64v8 \
## --name elasticsearch-5.6.3-arm64v8 \
## idu/elasticsearch-5.6.3:arm64v8
## 
## docker exec -u root -it elasticsearch-5.6.3-arm64v8 /bin/bash
