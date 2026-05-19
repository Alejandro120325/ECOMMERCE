# --- COMPILACIÓN MAVEN (Java 21) ---
FROM maven:3.9.6-eclipse-temurin-21 AS build
COPY . .
RUN mvn clean package -DskipTests

# --- CONTENEDOR APACHE TOMCAT ---
FROM tomcat:10.1-jdk21-openjdk-slim
COPY --from=build /target/*.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]