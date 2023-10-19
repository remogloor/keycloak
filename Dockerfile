FROM quay.io/keycloak/keycloak:19.0 as builder

USER root
ENV KC_METRICS_ENABLED=true
ENV KC_FEATURES=scripts
ENV KC_DB=postgres
ENV KC_HTTP_RELATIVE_PATH=/auth

ENV JBOSS_HOME /opt/keycloak
ENV PROVIDERS_VERSION 1.0.40
ENV PROVIDERS_TMP /tmp/keycloak-providers
ENV MAVEN_CENTRAL_URL https://repo1.maven.org/maven2

RUN microdnf update -y
RUN microdnf install -y zip
RUN microdnf clean all
RUN mkdir /tmpproviders

COPY /providers/ /tmpproviders/
WORKDIR /tmpproviders
RUN zip -r /opt/keycloak/providers/myproviders.jar *

RUN mkdir -p $PROVIDERS_TMP
ADD $MAVEN_CENTRAL_URL/ru/playa/keycloak/keycloak-russian-providers/$PROVIDERS_VERSION/keycloak-russian-providers-$PROVIDERS_VERSION.jar $PROVIDERS_TMP
ADD https://github.com/wadahiro/keycloak-discord/releases/download/v0.4.0/keycloak-discord-0.4.0.jar $PROVIDERS_TMP
RUN cp $PROVIDERS_TMP/keycloak-russian-providers-$PROVIDERS_VERSION.jar $JBOSS_HOME/providers
RUN cp $PROVIDERS_TMP/keycloak-discord-0.4.0.jar $JBOSS_HOME/providers
RUN chmod -R a+r $JBOSS_HOME
RUN rm -rf $PROVIDERS_TMP

RUN /opt/keycloak/bin/kc.sh build --features=scripts

FROM quay.io/keycloak/keycloak:17.0
USER root
RUN microdnf update -y
RUN microdnf install -y zip
RUN microdnf install -y vim
RUN microdnf install -y wget
RUN microdnf install -y iputils 
RUN microdnf clean all

COPY --from=builder /opt/keycloak/lib/quarkus/ /opt/keycloak/lib/quarkus/
COPY /providers/ /tmpproviders/
WORKDIR /tmpproviders
RUN zip -r /opt/keycloak/providers/myproviders.jar *

COPY cache-ispn-jdbc-ping.xml /opt/keycloak/conf/cache-ispn-jdbc-ping.xml
ENV KC_CACHE_CONFIG_FILE=cache-ispn-jdbc-ping.xml

ENV JBOSS_HOME /opt/keycloak
ENV PROVIDERS_VERSION 1.0.40
ENV PROVIDERS_TMP /tmp/keycloak-providers
ENV MAVEN_CENTRAL_URL https://repo1.maven.org/maven2

RUN mkdir -p $PROVIDERS_TMP
ADD $MAVEN_CENTRAL_URL/ru/playa/keycloak/keycloak-russian-providers/$PROVIDERS_VERSION/keycloak-russian-providers-$PROVIDERS_VERSION.jar $PROVIDERS_TMP
ADD https://github.com/wadahiro/keycloak-discord/releases/download/v0.4.0/keycloak-discord-0.4.0.jar $PROVIDERS_TMP
RUN cp $PROVIDERS_TMP/keycloak-russian-providers-$PROVIDERS_VERSION.jar $JBOSS_HOME/providers
RUN cp $PROVIDERS_TMP/keycloak-discord-0.4.0.jar $JBOSS_HOME/providers
RUN chmod -R a+r $JBOSS_HOME
RUN rm -rf $PROVIDERS_TMP

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
