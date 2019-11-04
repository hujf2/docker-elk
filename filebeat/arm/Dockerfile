FROM arm64v8/debian:stretch

MAINTAINER Andrea Usuelli <andrea.usuelli@prima.it>

ENV FILEBEAT_VERSION=6.8.4 \
    FILEBEAT_SHA1=7eebf3d5a599c39eb8756cbad48fb2f7dee4795a9d7edfc204ad6cb4b325840df215d4d24af79b939bcf735b455c4ad2d1fbce21b586d75ba2c2d6c48c1f25df

COPY ./config/sources.list /etc/apt/sources.list
COPY ./filebeat-${FILEBEAT_VERSION}-linux-x86_64.tar.gz /opt/filebeat.tar.gz
RUN set -x && \
  apt-get update && \
  apt-get install -y wget && \
  #wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${FILEBEAT_VERSION}-linux-x86_64.tar.gz -O /opt/filebeat.tar.gz && \
  cd /opt && \
  echo "${FILEBEAT_SHA1}  filebeat.tar.gz" | sha512sum -c - && \
  tar xzvf filebeat.tar.gz && \
  cd filebeat-* && \
  cp filebeat /bin && \
  cd /opt && \
  rm -rf filebeat* && \
  apt-get purge -y wget && \
  apt-get autoremove -y && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD [ "filebeat", "-e" ]

## ****************************** 参考资料 *****************************************
## 制作Docker Image: docker build -t elk/filebeat-6.8.4:arm64v8 .