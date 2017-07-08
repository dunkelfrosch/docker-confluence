#
# BUILD    : DF/[ATLASSIAN][CONFLUENCE]
# OS/CORE  : java:8-jdk
# SERVICES : ntp, ...
#
# VERSION 1.0.2
#

FROM java:8

MAINTAINER Patrick Paechnatz <patrick.paechnatz@gmail.com>
LABEL com.container.vendor="dunkelfrosch impersonate" \
      com.container.service="atlassian/confluence" \
      com.container.service.version="6.2.3" \
      com.container.priority="1" \
      com.container.project="confluence" \
      img.version="1.0.2" \
      img.description="atlassian confluence application container"

ENV TERM="xterm" \
    LC_ALL="C.UTF-8" \
    DEBIAN_FRONTEND="noninteractive" \
    TIMEZONE="Europe/Berlin" \
    CONFLUENCE_VERSION="6.2.3" \
    CONFLUENCE_HOME="/var/atlassian/confluence" \
    CONFLUENCE_INSTALL="/opt/atlassian/confluence" \
    DOWNLOAD_URL="http://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-" \
    JVM_MYSQL_CONNECTOR_URL="http://dev.mysql.com/get/Downloads/Connector-J" \
    JVM_MYSQL_CONNETOR="mysql-connector-java-5.1.36" \
    JAVA_HOME="/usr/lib/jvm/java-1.8.0-openjdk-amd64" \
    RUN_USER="daemon" \
    RUN_GROUP="daemon"

# x-layer 1: package manager related processor
RUN set -e \
    && apt-get update -qq \
    && apt-get install -qq -y --no-install-recommends software-properties-common debconf-utils libtcnative-1 xmlstarlet mc liblucene2-java ntp \
    && add-apt-repository "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main"
    && apt-get update -qq \
    && echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections \
    && echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections \
    && apt-get install -qq -y oracle-java8-installer \
    && apt-get clean autoclean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/cache /var/lib/log /tmp/* /var/tmp/*

# x-layer 2: application base setup related processor
RUN set -e \
    && mkdir -p ${CONFLUENCE_HOME} \
                ${CONFLUENCE_INSTALL}/conf \
                ${CONFLUENCE_INSTALL}/lib \
    && curl -Ls "${DOWNLOAD_URL}${CONFLUENCE_VERSION}.tar.gz" | tar -xz --strip=1 -C "${CONFLUENCE_INSTALL}" \
    && curl -Ls "${JVM_MYSQL_CONNECTOR_URL}/${JVM_MYSQL_CONNETOR}.tar.gz" | tar -xz --directory "${CONFLUENCE_INSTALL}/confluence/WEB-INF/lib" --strip=1 --no-same-owner "${JVM_MYSQL_CONNETOR}/${JVM_MYSQL_CONNETOR}-bin.jar" \
    && echo -e "\nconfluence.home=$CONFLUENCE_HOME" >> "${CONFLUENCE_INSTALL}/confluence/WEB-INF/classes/confluence-init.properties" \
    && chmod -R 700 ${CONFLUENCE_HOME} ${CONFLUENCE_INSTALL} \
    && chown -R ${RUN_USER}:${RUN_GROUP} ${CONFLUENCE_HOME} ${CONFLUENCE_INSTALL}

# x-layer 3: application advanced setup related processor
RUN set -e \
    && echo "${TIMEZONE}" >/etc/timezone \
    && dpkg-reconfigure tzdata >/dev/null 2>&1

#
# -> if you're running this confluence container outside a workbench scenario, you
#    can activate VOLUME feature ...
#
# Set volume mount points for installation and home directory. Changes to the
# home directory needs to be persisted as well as parts of the installation
# directory (accessing logs). These directories will be set-and-used during
# data-only container volume bound run-mode.
# VOLUME ["${CONFLUENCE_INSTALL}", "${CONFLUENCE_HOME}"]

# Expose default HTTP connector port.
EXPOSE 8090

# Next, set the default working directory as confluence home directory.
WORKDIR ${CONFLUENCE_INSTALL}

# Set base container execution user/group (no root-right container allowed here)
# using the default unprivileged account.
USER ${RUN_USER}:${RUN_GROUP}

# Finally, run Atlassian confluence as a foreground process by default.
CMD ["/opt/atlassian/confluence/bin/start-confluence.sh", "-fg"]
