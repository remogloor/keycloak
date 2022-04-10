FROM quay.io/keycloak/keycloak:latest as builder

USER root
ENV KC_METRICS_ENABLED=true
ENV KC_FEATURES=scripts
ENV KC_DB=postgres
ENV KC_HTTP_RELATIVE_PATH=/auth
RUN microdnf update -y
RUN microdnf install -y zip
RUN microdnf clean all
RUN mkdir /tmpproviders
COPY /providers/ /tmpproviders/
WORKDIR /tmpproviders
RUN zip -r /opt/keycloak/providers/myproviders.jar *
RUN /opt/keycloak/bin/kc.sh build --features=scripts

FROM quay.io/keycloak/keycloak:latest
USER root
RUN microdnf update -y
RUN microdnf install -y zip
RUN microdnf install -y vim
RUN microdnf clean all
USER 1000

COPY --from=builder /opt/keycloak/lib/quarkus/ /opt/keycloak/lib/quarkus/
COPY /providers/ /tmpproviders/
WORKDIR /tmpproviders
RUN zip -r /opt/keycloak/providers/myproviders.jar /tmpproviders/*

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
