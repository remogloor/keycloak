FROM registry.access.redhat.com/ubi9-minimal AS zipper

RUN microdnf update -y
RUN microdnf install -y zip
RUN microdnf clean all
RUN mkdir /tmpproviders
RUN mkdir /result

COPY /providers/ /tmpproviders/
WORKDIR /tmpproviders
RUN zip -r /result/myproviders.jar *

FROM registry.access.redhat.com/ubi9 AS packageprovider
RUN mkdir -p /mnt/rootfs
RUN dnf install --installroot /mnt/rootfs vim wget iputils curl find --releasever 9 --setopt install_weak_deps=false --nodocs -y; dnf --installroot /mnt/rootfs clean all

FROM quay.io/keycloak/keycloak:22.0 as builder

USER root
ENV KC_METRICS_ENABLED=true
ENV KC_FEATURES=scripts
ENV KC_DB=postgres
ENV KC_HTTP_RELATIVE_PATH=/auth

ENV JBOSS_HOME /opt/keycloak
ENV PROVIDERS_VERSION 22.0.3.rsp
ENV PROVIDERS_TMP /tmp/keycloak-providers
ENV MAVEN_CENTRAL_URL https://repo1.maven.org/maven2

COPY --from=zipper /result/ /opt/keycloak/providers/

RUN mkdir -p $PROVIDERS_TMP
ADD $MAVEN_CENTRAL_URL/ru/playa/keycloak/keycloak-russian-providers/$PROVIDERS_VERSION/keycloak-russian-providers-$PROVIDERS_VERSION.jar $PROVIDERS_TMP
ADD https://github.com/wadahiro/keycloak-discord/releases/download/v0.5.0/keycloak-discord-0.5.0.jar $PROVIDERS_TMP
RUN cp $PROVIDERS_TMP/keycloak-russian-providers-$PROVIDERS_VERSION.jar $JBOSS_HOME/providers
RUN cp $PROVIDERS_TMP/keycloak-discord-0.5.0.jar $JBOSS_HOME/providers
RUN chmod -R a+r $JBOSS_HOME
RUN rm -rf $PROVIDERS_TMP

COPY cache-ispn-jdbc-ping.xml /opt/keycloak/conf/cache-ispn-jdbc-ping.xml
ENV KC_CACHE_CONFIG_FILE=cache-ispn-jdbc-ping.xml

RUN /opt/keycloak/bin/kc.sh build --features=scripts --cache-config-file=cache-ispn-jdbc-ping.xml

FROM quay.io/keycloak/keycloak:22.0
COPY --from=packageprovider /mnt/rootfs /
USER root

COPY --from=builder /opt/keycloak/lib/quarkus/ /opt/keycloak/lib/quarkus/
COPY --from=zipper /result/ /opt/keycloak/providers/

ENV JBOSS_HOME /opt/keycloak
ENV PROVIDERS_VERSION 22.0.3.rsp
ENV PROVIDERS_TMP /tmp/keycloak-providers
ENV MAVEN_CENTRAL_URL https://repo1.maven.org/maven2
RUN mkdir -p $PROVIDERS_TMP
ADD $MAVEN_CENTRAL_URL/ru/playa/keycloak/keycloak-russian-providers/$PROVIDERS_VERSION/keycloak-russian-providers-$PROVIDERS_VERSION.jar $PROVIDERS_TMP
ADD https://github.com/wadahiro/keycloak-discord/releases/download/v0.5.0/keycloak-discord-0.5.0.jar $PROVIDERS_TMP
RUN cp $PROVIDERS_TMP/keycloak-russian-providers-$PROVIDERS_VERSION.jar $JBOSS_HOME/providers
RUN cp $PROVIDERS_TMP/keycloak-discord-0.5.0.jar $JBOSS_HOME/providers
RUN chmod -R a+r $JBOSS_HOME
RUN rm -rf $PROVIDERS_TMP

COPY cache-ispn-jdbc-ping.xml /opt/keycloak/conf/cache-ispn-jdbc-ping.xml
ENV KC_CACHE_CONFIG_FILE=cache-ispn-jdbc-ping.xml

USER 1000

WORKDIR /opt/keycloak

# for demonstration purposes only, please make sure to use proper certificates in production instead
RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=keycloak" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" -keystore conf/server.keystore

ENV KEYCLOAK_ADMIN=admin
ENV KEYCLOAK_ADMIN_PASSWORD=change_me

# change these values to point to a running postgres instance
ENV KC_DB_URL=postgres
ENV KC_DB_USERNAME=keycloak
ENV KC_DB_PASSWORD=change_me
ENV KC_FEATURES=scripts

ENV KC_PROXY=edge
ENV KC_HTTP_ENABLED=true
ENV KC_HOSTNAME_STRICT=false

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
