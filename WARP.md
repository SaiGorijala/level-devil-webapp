# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Overview

This repository is a minimal **Java 17 / Maven** web application skeleton for a Level Devil-style game, packaged as a WAR for deployment to a Jakarta Servlet 6 container (e.g., Tomcat 10.1+).

Key technologies:
- Java 17
- Maven (WAR packaging)
- Jakarta Servlet API 6 (container-provided)

Authoritative basics are in `README.md`; this file focuses on commands and architecture useful to agents.

## Commands

### Build

Full clean build and WAR packaging (from `README.md`):

```bash
mvn clean package
```

Outputs: `target/level-devil-webapp.war`.

### Tests

JUnit 5 is wired via `maven-surefire-plugin` and the `org.junit.jupiter:junit-jupiter` dependency.

- Run the full test suite:

  ```bash
  mvn test
  ```

- Run a single test class (replace `MyServletTest` with the actual test class name):

  ```bash
  mvn -Dtest=MyServletTest test
  ```

- Run a single test method:

  ```bash
  mvn -Dtest=MyServletTest#myTestMethod test
  ```

There are currently no custom test source files checked in; these commands become relevant once tests are added under `src/test/java`.

### Lint / static analysis

No dedicated lint/static-analysis plugins (e.g., Checkstyle, SpotBugs) are configured in `pom.xml`. Use standard Maven compilation as the primary automated check:

```bash
mvn compile
```

If you add linting plugins in the future, document their invocation here.

## Deployment

From `README.md`:

1. Build the WAR:

   ```bash
   mvn clean package
   ```

2. Deploy `target/level-devil-webapp.war` to a Jakarta Servlet 6–compatible container (such as Tomcat 10.1+).

Container configuration and deployment steps are managed outside this repository.

## High-level Architecture

This is a traditional servlet/JSP webapp with WAR packaging. The core pieces are:

### Maven project

- `pom.xml`
  - Group/artifact: `com.example:level-devil-webapp`
  - Packaging: `war`
  - Java version: 17 (`maven.compiler.source` / `maven.compiler.target`).
  - Dependencies:
    - `jakarta.servlet:jakarta.servlet-api` with `provided` scope (supplied by the container).
    - `org.junit.jupiter:junit-jupiter` for tests.
  - Plugins:
    - `maven-compiler-plugin` for Java compilation.
    - `maven-war-plugin` to build `level-devil-webapp.war`.
    - `maven-surefire-plugin` to run JUnit tests.

### Web layer

- `src/main/java/com/example/leveldevil/LevelDevilServlet.java`
  - A single `HttpServlet` mapped to `/` via `@WebServlet(name = "LevelDevilServlet", urlPatterns = {"/"})`.
  - Handles `GET` requests by writing a minimal HTML page directly with a `PrintWriter`.
  - This class is the current dynamic entry point of the application and is the natural place to evolve server-side game logic or to delegate into a future service layer.

- `src/main/webapp/index.jsp`
  - Simple JSP that renders a confirmation-style landing page indicating the skeleton is deployed correctly.
  - Listed as the welcome file in `web.xml` (see below), so it will be served as the default resource.

- `src/main/webapp/WEB-INF/web.xml`
  - Declares the web application metadata (display name, welcome file list) using the Jakarta EE 6 schema.
  - Currently relies on `@WebServlet` for servlet mapping, so it only configures `index.jsp` as the welcome file. This file is the right place to add filters, listeners, or additional servlet configuration if annotation-based configuration is not sufficient.

### Request flow (big picture)

1. The servlet container receives an HTTP request for this application.
2. If the request is for the root path and no more specific mapping applies, `index.jsp` is served as the welcome file.
3. Requests matching the `/` pattern and resolved to the servlet (depending on container mapping resolution) are handled by `LevelDevilServlet#doGet`, which writes HTML directly.
4. As the project grows, you can:
   - Add more servlets under `src/main/java/com/example/leveldevil` (or subpackages) and map them via annotations or `web.xml`.
   - Expand `index.jsp` into a more feature-rich UI, or add additional JSPs/HTML under `src/main/webapp`.
   - Introduce static assets (images, sounds, styles) under `src/main/webapp` as suggested in `README.md`.

## Notes for Future Warp Agents

- Prefer using Maven lifecycle commands (`compile`, `test`, `package`) over direct `javac`/manual deployment steps.
- When adding tests, follow JUnit 5 naming conventions under `src/test/java` so that the existing `maven-surefire-plugin` setup picks them up automatically.
- If you introduce additional frameworks (e.g., Spring MVC or a game engine library), update this file’s Architecture and Commands sections to reflect the new entry points and tooling.