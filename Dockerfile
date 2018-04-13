#
# BUILD    : DF/[ATLASSIAN][CONFLUENCE]
# OS/CORE  : openjdk:8-jdk-alpine
# SERVICES : ntp, ...
#
# VERSION 1.0.3
#

FROM openjdk:8-jdk-alpine

LABEL maintainer="Patrick Paechnatz <patrick.paechnatz@gmail.com>" \
      com.container.vendor="dunkelfrosch impersonate" \
      com.container.service="atlassian/confluence" \
      com.container.priority="1" \
      com.container.project="confluence" \
      img.version="1.0.3" \
      img.description="atlassian confluence application container"

ARG CONFLUENCE_VERSION=6.8.1
ARG MYSQL_CONNECTOR_VERSION=5.1.46

ENV TERM="xterm" \
    LC_ALL="C.UTF-8" \
    TIMEZONE="Europe/Berlin" \
    CONFLUENCE_HOME="/var/atlassian/application-data/confluence" \
    CONFLUENCE_INSTALL_DIR="/opt/atlassian/confluence" \
    CONFLUENCE_DOWNLOAD_URL="http://www.atlassian.com/software/confluence/downloads/binary" \
    JVM_MYSQL_CONNECTOR_URL="http://dev.mysql.com/get/Downloads/Connector-J" \
    RUN_USER="daemon" \
    RUN_GROUP="daemon"

COPY entrypoint.sh /entrypoint.sh

# install base os packages
RUN set -e \
    && apk update -qq \
    && update-ca-certificates \
    && apk add ca-certificates wget curl openssh bash procps openssl perl ttf-dejavu tini libc6-compat

# download/prepare confluence
RUN set -e \
    && mkdir -p  ${CONFLUENCE_HOME} \
                 ${CONFLUENCE_INSTALL_DIR}/conf \
                 ${CONFLUENCE_INSTALL_DIR}/lib \
                 ${CONFLUENCE_INSTALL_DIR}/confluence/WEB-INF/lib \
    && curl -Ls "${CONFLUENCE_DOWNLOAD_URL}/atlassian-confluence-${CONFLUENCE_VERSION}.tar.gz" | tar -xz --strip-components=1 -C "${CONFLUENCE_INSTALL_DIR}"

# download/prepare mysql connector
RUN set -e \
    && curl -Ls "${JVM_MYSQL_CONNECTOR_URL}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.tar.gz" | tar -xz --strip-components=1 -C "/tmp" \
    && mv /tmp/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}-bin.jar ${CONFLUENCE_INSTALL_DIR}/confluence/WEB-INF/lib \
    && sed -i -e 's/-Xms\([0-9]\+[kmg]\) -Xmx\([0-9]\+[kmg]\)/-Xms\${JVM_MINIMUM_MEMORY:=\1} -Xmx\${JVM_MAXIMUM_MEMORY:=\2} \${JVM_SUPPORT_RECOMMENDED_ARGS} -Dconfluence.home=\${CONFLUENCE_HOME}/g' ${CONFLUENCE_INSTALL_DIR}/bin/setenv.sh \
    && sed -i -e 's/port="8090"/port="8090" secure="${catalinaConnectorSecure}" scheme="${catalinaConnectorScheme}" proxyName="${catalinaConnectorProxyName}" proxyPort="${catalinaConnectorProxyPort}"/' ${CONFLUENCE_INSTALL_DIR}/conf/server.xml \
    && chown -R ${RUN_USER}:${RUN_GROUP} ${CONFLUENCE_HOME} ${CONFLUENCE_INSTALL_DIR} /entrypoint.sh \
    && chmod -R 700 ${CONFLUENCE_HOME} ${CONFLUENCE_INSTALL_DIR} \
    && chmod +x /entrypoint.sh

# clear cache
RUN rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/* /var/tmp/*

# define container execution behaviour
VOLUME ["${CONFLUENCE_HOME}"]
WORKDIR $CONFLUENCE_HOME
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/entrypoint.sh", "-fg"]
