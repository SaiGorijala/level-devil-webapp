# -------- Stage 1: Downloader --------
FROM eclipse-temurin:17-jre AS downloader

ARG NEXUS_URL
ARG GROUP_ID_PATH
ARG APP_NAME
ARG VERSION
ARG NEXUS_USER
ARG NEXUS_PASS

# Compute the artifact URL INSIDE Docker
ENV ARTIFACT_URL="${NEXUS_URL}${GROUP_ID_PATH}/${APP_NAME}/${VERSION}/${APP_NAME}-${VERSION}.war"

RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Download WAR from Nexus
RUN echo "Downloading WAR from: $ARTIFACT_URL" && \
    curl -u "$NEXUS_USER:$NEXUS_PASS" -L "$ARTIFACT_URL" -o /tmp/app.war

# -------- Stage 2: Tomcat --------
FROM tomcat:10.1-jdk17-temurin

RUN rm -rf /usr/local/tomcat/webapps/ROOT

COPY --from=downloader /tmp/app.war /usr/local/tomcat/webapps/ROOT.war
