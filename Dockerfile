# Build stage: compile and package the jar
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn -q -B dependency:go-offline
COPY src ./src
RUN mvn -q -B -DskipTests package

# Run stage: a small image with only the Java runtime
FROM eclipse-temurin:17-jre
WORKDIR /app
RUN useradd --system --uid 1001 campus && mkdir -p /data/uploads && chown -R campus /data
COPY --from=build /app/target/*.jar /app/app.jar
USER campus
ENV SPRING_PROFILES_ACTIVE=prod UPLOAD_DIR=/data/uploads
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
