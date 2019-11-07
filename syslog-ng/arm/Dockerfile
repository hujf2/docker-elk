FROM arm64v8/fedora:31

ARG SYSLOG_VERSION="3.22.1"

COPY ./config/fedora-163.repo /etc/yum.repos.d/fedora-163.repo
COPY ./config/fedora-updates-163.repo /etc/yum.repos.d/fedora-updates-163.repo
COPY ./config/fedora-aliyun.repo /etc/yum.repos.d/fedora-aliyun.repo
COPY ./config/fedora-updates-aliyun.repo /etc/yum.repos.d/fedora-updates-aliyun.repo
COPY ./config/fedora-sjtu.repo /etc/yum.repos.d/fedora-sjtu.repo
COPY ./config/fedora-local.repo /etc/yum.repos.d/fedora-local.repo
COPY get-pip.py ./

RUN set -x; \
    yum clean all; \
    yum makecache; \
	yum install -y yum-fastestmirror yum-presto; \
	yum update -y; \
	# https://getfedora.org/zh_TW/server/download/
	# https://www.tecmint.com/install-java-in-fedora/
	yum install -y java-1.8.0-openjdk.aarch64 \
	               gcc librdkafka  librdkafka-devel \
				   findutils

	
RUN yum install -y eventlog syslog-ng syslog-ng-libdbi syslog-ng-http; \
    # Install all syslog-ng module
	yum search syslog-ng-*; \
	yum install -y syslog-ng-*; \
	# https://stackoverflow.com/questions/11094718/error-command-gcc-failed-with-exit-status-1-while-installing-eventlet
	# https://stackoverflow.com/questions/21530577/fatal-error-python-h-no-such-file-or-directory
	# https://github.com/edenhill/librdkafka
	yum install -y python python3-devel; \
	python get-pip.py; \
	pip install syslogng_kafka
	
# Fix: Error opening plugin module; module='mod-java', error='libjvm.so: cannot open shared object file: No such file or directory'
RUN find /usr/lib/ -name 'libjvm.so*' | xargs dirname | tee --append /etc/ld.so.conf.d/openjdk-libjvm.conf; \
	ldconfig; \
	# Replace the system() source because inside Docker we can't access /proc/kmsg.
    # https://groups.google.com/forum/#!topic/docker-user/446yoB0Vx6w
    sed -i -E 's/^(\s*)system\(\);/\1unix-stream("\/dev\/log");/' /etc/syslog-ng/syslog-ng.conf

EXPOSE 514/udp
EXPOSE 601/tcp
EXPOSE 6514/tcp

ENTRYPOINT ["/usr/sbin/syslog-ng", "--no-caps", "-F"]

## ****************************** 参考资料 *****************************************
## 制作Docker Image: docker build --no-cache -t elk/syslog-ng-3.20.1:arm64v8 .
##
## docker build -t elk/syslog-ng-3.22.1:arm64v8 .
##
## https://github.com/mumblepins-docker/syslog-ng-alpine/blob/master/Dockerfile
## https://github.com/moonbuggy/docker-syslog-ng-alpine
## https://github.com/balabit/syslog-ng-docker/tree/master/syslog-ng-dev
## https://packages.debian.org/search?keywords=syslog-ng-mod-kafka
## https://syslogng-kafka.readthedocs.io/en/latest/installation.html
