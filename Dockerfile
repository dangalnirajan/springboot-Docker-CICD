# Stage 1: Build the Spring Boot application
FROM maven:3.8-openjdk-17 AS build

WORKDIR /app

# Copy the Maven project files
COPY pom.xml .
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests

# Stage 2: Create a lightweight production image for the Spring Boot application
FROM openjdk:17-jdk-slim

# Set the working directory
WORKDIR /app

# Copy the JAR file from the build stage
COPY --from=build /app/target/spring-boot-crud-rest-1.1.0.jar /app/application.jar

# Run the application as a non-root user for better security
RUN adduser --disabled-password --gecos "" springuser
USER springuser

# Expose the port that the Spring Boot application listens on
EXPOSE 9191

# Start the Spring Boot application
ENTRYPOINT ["java", "-jar", "/app/application.jar"]
