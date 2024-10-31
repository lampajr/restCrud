FROM icr.io/appcafe/open-liberty:kernel-slim-java11-openj9-ubi

COPY --chown=1001:0 src/main/liberty/config/server.xml /config/server.xml
COPY --chown=1001:0 src/main/liberty/config/jvm.options /config/jvm.options

RUN features.sh

COPY --chown=1001:0 resources /opt/ol/wlp/usr/shared/resources
COPY --chown=1001:0 target/rest-crud.war /config/apps

RUN configure.sh
