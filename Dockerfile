# ----- Stage 1: download WAR from Nexus -----
FROM eclipse-temurin:17-jre AS downloader

ARG ARTIFACT_URL
ARG NEXUS_USER
ARG NEXUS_PASS
ARG ARTIFACT_NAME=level-devil-webapp.war

RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

RUN curl -u "${NEXUS_USER}:${NEXUS_PASS}" -L "${ARTIFACT_URL}" -o "/tmp/${ARTIFACT_NAME}"

# ----- Stage 2: final runtime image with Tomcat 10 (Jakarta EE 10 / Servlet 6) -----
FROM tomcat:10.1-jdk17-temurin

ENV CATALINA_OPTS="-Xms256m -Xmx512m"

# Remove default ROOT app
RUN rm -rf /usr/local/tomcat/webapps/ROOT

# Copy downloaded WAR as ROOT.war
COPY --from=downloader /tmp/level-devil-webapp.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
