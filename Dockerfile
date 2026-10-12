
FROM eclipse-temurin:21-jdk-jammy AS builder
WORKDIR /app

COPY .mvn/ .mvn/
COPY mvnw pom.xml ./
RUN chmod +x mvnw
RUN ./mvnw dependency:resolve

COPY src/ src/
RUN ./mvnw package -DskipTests

FROM builder AS development
CMD ["./mvnw", "spring-boot:run", "-Dspring-boot.run.profiles=mysql", "-Dspring-boot.run.jvmArguments=-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:8000"]

FROM eclipse-temurin:21-jre-jammy AS production
WORKDIR /app
EXPOSE 8085
COPY --from=builder /app/target/spring-petclinic-*.war /spring-petclinic.war
CMD ["java", "-jar", "/spring-petclinic.war"]
