FROM debian:stretch
MAINTAINER Andras Mitzki <andras.mitzki@balabit.com>

COPY ./conf/sources.list /etc/apt/sources.list
RUN apt-get update -qq && apt-get install -y \
    wget \
    gnupg2

RUN wget -qO - https://download.opensuse.org/repositories/home:/laszlo_budai:/syslog-ng/Debian_9.0/Release.key | apt-key add -
RUN echo 'deb http://download.opensuse.org/repositories/home:/laszlo_budai:/syslog-ng/Debian_9.0 ./' | tee --append /etc/apt/sources.list.d/syslog-ng-obs.list

RUN apt-get update -qq && apt-get install -y \
    syslog-ng

# ADD syslog-ng.conf /etc/syslog-ng/syslog-ng.conf

RUN find /usr/lib/ -name 'libjvm.so*' | xargs dirname | tee --append /etc/ld.so.conf.d/openjdk-libjvm.conf
RUN ldconfig
    # Replace the system() source because inside Docker we can't access /proc/kmsg.
    # https://groups.google.com/forum/#!topic/docker-user/446yoB0Vx6w
    sed -i -E 's/^(\s*)system\(\);/\1unix-stream("\/dev\/log");/' /etc/syslog-ng/syslog-ng.conf
    # Uncomment 'SYSLOGNG_OPTS="--no-caps"' to avoid the following warning:
    # syslog-ng: Error setting capabilities, capability management disabled; error='Operation not permitted'
    # http://serverfault.com/questions/524518/error-setting-capabilities-capability-management-disabled#
    # sed -i 's/^#\(SYSLOGNG_OPTS="--no-caps"\)/\1/g' /etc/default/syslog

EXPOSE 514/udp
EXPOSE 601/tcp
EXPOSE 6514/tcp

#ENTRYPOINT ["/usr/sbin/syslog-ng", "-F"]
ENTRYPOINT ["/usr/sbin/syslog-ng", "--no-caps", "-F"]

## ****************************** 参考资料 *****************************************
## 制作Docker Image: docker build --no-cache -t idu/syslog-ng-3.24.1:amd .
#
# docker build -t idu/syslog-ng-3.24.1:amd .
#
# docker run -it \
# -p 514:514/udp \
# -p 601:601 \
# -v /var/log/syslog-ng:/var/log/syslog-ng \
# --name syslog-ng \
# idu/syslog-ng-3.24.1:amd
# 

