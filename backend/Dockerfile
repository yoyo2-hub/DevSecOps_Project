FROM maven:3.9-eclipse-temurin-17-alpine AS build

WORKDIR /app

COPY pom.xml .
COPY src ./src

RUN mvn -q -DskipTests package

FROM eclipse-temurin:17-jdk-alpine

WORKDIR /app

RUN apk add --no-cache bash netcat-openbsd

COPY --from=build /app/target/*.jar /app/app.jar

ENTRYPOINT ["sh","-c","until nc -z db 5432; do echo waiting for db; sleep 2; done; java -jar /app/app.jar"]