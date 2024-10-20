
FROM maven:3.8-openjdk-17 AS build

WORKDIR /app

COPY pom.xml .
COPY src ./src

RUN mvn clean package -DskipTests

FROM openjdk:17-jdk-slim

WORKDIR /app

COPY --from=build /app/target/spring-boot-crud-rest-1.1.0.jar /app/application.jar

RUN adduser --disabled-password --gecos "" springuser
USER springuser
EXPOSE 9191

ENTRYPOINT ["java", "-jar", "/app/application.jar"]
