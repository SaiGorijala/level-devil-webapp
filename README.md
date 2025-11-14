# Level Devil Web Application (Java, Maven)

This project is a **Java web application skeleton** intended as a starting point for a Level Devil-style game implemented as a traditional WAR-deployed webapp.

## Tech Stack

- Java 17
- Maven (WAR packaging)
- Jakarta Servlet API 6 (servlet container such as Tomcat, Jetty, etc.)

## Structure

- `pom.xml` – Maven build descriptor
- `src/main/java/com/example/leveldevil/LevelDevilServlet.java` – minimal servlet entry point
- `src/main/webapp/index.jsp` – placeholder landing page
- `src/main/webapp/WEB-INF/web.xml` – web application descriptor

## Build

```bash
mvn clean package
```

This will produce `target/level-devil-webapp.war`.

## Deploy

Deploy the generated WAR to a compatible Jakarta Servlet 6 container (e.g., Tomcat 10.1+).

## Next Steps

- Implement real Level Devil gameplay mechanics (levels, hazards, physics).
- Add static assets (images, sounds, styles) under `src/main/webapp`.
- Expand servlet/JSPs or migrate to a modern framework if desired.

## Git

A git repository is initialized in this directory. Configure a remote (e.g., GitHub) and push:

```bash
git remote add origin <YOUR_REMOTE_URL>
git push -u origin main
```
