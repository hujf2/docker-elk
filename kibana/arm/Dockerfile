FROM arm64v8/debian:stretch

COPY ./config/sources.list /etc/apt/sources.list
# add our user and group first to make sure their IDs get assigned consistently
RUN groupadd -r kibana && useradd -r -m -g kibana kibana

RUN apt-get update && apt-get install -y \
        ca-certificates \
        wget \
    --no-install-recommends

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
	&& apt-get install -y --no-install-recommends ca-certificates curl unzip gnupg gnupg2 dirmngr \
	&& rm -rf /var/lib/apt/lists/* \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

# grab tini for signal processing and zombie killing
# download from https://github.com/krallin/tini/releases
#ENV TINI_VERSION v0.18.0
COPY ./tini-arm64 /usr/local/bin/tini
COPY ./tini-arm64.asc /usr/local/bin/tini.asc
RUN set -x \
    && chmod +x /usr/local/bin/tini \
    && tini -h

# install kibana
ENV KIBANA_VERSION 6.8.4
COPY ./kibana-6.8.4-linux-x86_64.tar.gz /tmp/kibana-6.8.4-linux-x86_64.tar.gz
RUN set -x && \
    cd /tmp && \
    # && wget "https://download.elastic.co/kibana/kibana/kibana-$KIBANA_VERSION-linux-x86_64.tar.gz" \
    tar -xvzf kibana-$KIBANA_VERSION-linux-x86_64.tar.gz && \
    mv /tmp/kibana-$KIBANA_VERSION-linux-x86_64 /opt/kibana && \
    rm /tmp/kibana-$KIBANA_VERSION-linux-x86_64.tar.gz && \
    chown -R kibana:kibana /opt/kibana && \
    chmod o+w /opt/kibana/optimize/.babelcache.json && \
    sed -i 's/--no-warnings/--no-warnings --max_old_space_size=3072/' /opt/kibana/bin/kibana

# install arm version of node
#RUN set -x && \
#    wget http://node-arm.herokuapp.com/node_latest_armhf.deb && \
#    DEBIAN_FRONTEND=noninteractive dpkg -i node_latest_armhf.deb && \
#    ln -sf /usr/local/bin/node /opt/kibana/node/bin/node && \
#    ln -sf /usr/local/bin/npm /opt/kibana/node/bin/npm && \
#    node -v && \
#    npm -v

# replace amd64 node with arm64
#RUN rm -rf /usr/share/kibana/node/* && \
#    curl -sL https://nodejs.org/dist/v10.15.2/node-v10.15.2-linux-arm64.tar.gz | tar -C /usr/share/kibana/node/ --strip-components=1 -xzf -
# ubuntu18.04安装最新nodejs - https://blog.csdn.net/zyccode/article/details/90106478
# https://github.com/nodejs/node/blob/master/BUILDING.md#building-nodejs-on-supported-platforms
# https://nodejs.org/fr/blog/release/v13.0.1/
ENV NODE_HOME /opt/kibana/node
ENV PATH $NODE_HOME/bin:$PATH

COPY ./node-v10.15.2-linux-arm64.tar.gz ./node-v10.15.2-linux-arm64.tar.gz
RUN rm -rf /opt/kibana/node/* && \
    tar -xvf ./node-v10.15.2-linux-arm64.tar.gz -C /opt/kibana/node/ --strip-components=1 && \
    ln -sf /opt/kibana/node/bin/node /usr/local/bin/node && \
    ln -sf /opt/kibana/node/bin/npm /usr/local/bin/npm && \
    node -v && \
    npm -v

ENV PATH /opt/kibana/bin:$PATH

COPY docker-entrypoint.sh /
COPY ./config/kibana.yml /opt/kibana/config/kibana.yml
RUN chmod +x /docker-entrypoint.sh && \
    chown -R kibana:kibana /opt/kibana/config/kibana.yml
	
VOLUME ["/opt/kibana/data/"]
EXPOSE 5601

WORKDIR /opt/kibana

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["kibana"]
## ****************************** 参考资料 *****************************************
## 制作Docker Image: docker build -t elk/kibana-6.8.4:arm64v8 .