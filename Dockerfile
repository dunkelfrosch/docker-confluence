#
# BUILD    : DF/[ATLASSIAN][CONFLUENCE]
# OS/CORE  : blacklabelops/java:server-jre.8.162
# SERVICES : ntp, ...
#
# VERSION 1.0.6-ext
#

FROM blacklabelops/java:server-jre.8.162

LABEL maintainer="Patrick Paechnatz <patrick.paechnatz@gmail.com>" \
      com.container.vendor="dunkelfrosch impersonate" \
      com.container.service="atlassian/confluence" \
      com.container.priority="1" \
      com.container.project="confluence" \
      img.version="1.0.6" \
      img.description="atlassian confluence application container"

ARG CONFLUENCE_VERSION=6.12.2
ARG CONTAINER_UID=1000
ARG CONTAINER_GID=1000
ARG BUILD_DATE=undefined
ARG LANG_LANGUAGE=en
ARG LANG_COUNTRY=US

ENV CONF_HOME=/var/atlassian/confluence \
    CONF_INSTALL=/opt/atlassian/confluence \
    MYSQL_DRIVER_VERSION=5.1.47

RUN mkdir -p ${CONF_HOME} \
             ${CONF_INSTALL}/conf

RUN export CONTAINER_USER=confluence && \
    export CONTAINER_GROUP=confluence && \
    addgroup -g $CONTAINER_GID $CONTAINER_GROUP && \
    adduser  -u $CONTAINER_UID -G $CONTAINER_GROUP -h /home/$CONTAINER_USER -s /bin/bash -S $CONTAINER_USER

RUN apk add --update -f fc-cache update-ms-fonts ca-certificates gzip curl tar xmlstarlet msttcorefonts-installer ttf-dejavu fontconfig ghostscript graphviz motif wget update-ms-fonts && \
    fc-cache -f && update-ms-fonts && \
    /usr/glibc-compat/bin/localedef -i ${LANG_LANGUAGE}_${LANG_COUNTRY} -f UTF-8 ${LANG_LANGUAGE}_${LANG_COUNTRY}.UTF-8

RUN wget -q -O /tmp/atlassian-confluence-${CONFLUENCE_VERSION}.tar.gz http://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-${CONFLUENCE_VERSION}.tar.gz && \
    tar xzf /tmp/atlassian-confluence-${CONFLUENCE_VERSION}.tar.gz --strip-components=1 -C ${CONF_INSTALL} && \
    echo "confluence.home=${CONF_HOME}" > ${CONF_INSTALL}/confluence/WEB-INF/classes/confluence-init.properties

RUN rm -f ${CONF_INSTALL}/lib/mysql-connector-java*.jar && \
    wget -q -O /tmp/mysql-connector-java-${MYSQL_DRIVER_VERSION}.tar.gz http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_DRIVER_VERSION}.tar.gz && \
    tar xzf /tmp/mysql-connector-java-${MYSQL_DRIVER_VERSION}.tar.gz -C /tmp && \
    cp /tmp/mysql-connector-java-${MYSQL_DRIVER_VERSION}/mysql-connector-java-${MYSQL_DRIVER_VERSION}-bin.jar ${CONF_INSTALL}/lib/mysql-connector-java-${MYSQL_DRIVER_VERSION}-bin.jar

RUN export KEYSTORE=$JAVA_HOME/jre/lib/security/cacerts && \
    wget -q -P /tmp/ https://letsencrypt.org/certs/letsencryptauthorityx1.der && \
    wget -q -P /tmp/ https://letsencrypt.org/certs/letsencryptauthorityx2.der && \
    wget -q -P /tmp/ https://letsencrypt.org/certs/lets-encrypt-x1-cross-signed.der && \
    wget -q -P /tmp/ https://letsencrypt.org/certs/lets-encrypt-x2-cross-signed.der && \
    wget -q -P /tmp/ https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.der && \
    wget -q -P /tmp/ https://letsencrypt.org/certs/lets-encrypt-x4-cross-signed.der && \
    keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias isrgrootx1 -file /tmp/letsencryptauthorityx1.der && \
    keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias isrgrootx2 -file /tmp/letsencryptauthorityx2.der && \
    keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias letsencryptauthorityx1 -file /tmp/lets-encrypt-x1-cross-signed.der && \
    keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias letsencryptauthorityx2 -file /tmp/lets-encrypt-x2-cross-signed.der && \
    keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias letsencryptauthorityx3 -file /tmp/lets-encrypt-x3-cross-signed.der && \
    keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias letsencryptauthorityx4 -file /tmp/lets-encrypt-x4-cross-signed.der && \
    wget -q -O /home/${CONTAINER_USER}/SSLPoke.class https://confluence.atlassian.com/kb/files/779355358/779355357/1/1441897666313/SSLPoke.class

RUN chown -R confluence:confluence /home/${CONTAINER_USER} ${CONF_INSTALL} ${CONF_HOME} && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/* /var/tmp/*

EXPOSE 8090 8091

USER confluence

VOLUME ["/var/atlassian/confluence"]

WORKDIR ${CONF_HOME}

COPY docker-entrypoint.sh /home/confluence/docker-entrypoint.sh

ENTRYPOINT ["/sbin/tini","--","/home/confluence/docker-entrypoint.sh"]
CMD ["confluence"]
