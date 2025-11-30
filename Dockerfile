# Use official Tomcat image (has Java)
FROM tomcat:9.0

# Remove default ROOT app (optional)
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy built WAR into Tomcat webapps as ROOT.war so it serves at '/'
COPY target/*.war /usr/local/tomcat/webapps/ROOT.war

# Expose Tomcat port
EXPOSE 8080

# Start Tomcat (default CMD already does this)
