FROM maven:3.9-eclipse-temurin-21 AS build

WORKDIR /eureka-server

COPY pom.xml .
RUN mvn -B -q -e -DskipTests dependency:go-offline

COPY src ./src

RUN mvn clean package -DskipTests

FROM eclipse-temurin:21-jre-jammy
WORKDIR /eureka-server

RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

COPY --from=build /eureka-server/target/*.jar eureka-server.jar

EXPOSE 8761

ENTRYPOINT ["java", "-jar", "eureka-server.jar"]

HEALTHCHECK --interval=30s --timeout=5s \
  CMD curl -f http://localhost:8761/actuator/health || exit 1
