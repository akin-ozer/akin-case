# Use an official Maven image as the base image
FROM maven:3.8.4-openjdk-11-slim AS build
# Set the working directory in the container
WORKDIR /app
# Copy the pom.xml and the project files to the container
COPY pom.xml .
COPY src ./src
# Build the application using Maven
RUN mvn clean package -DskipTests
# Use an official OpenJDK image as the base image
FROM openjdk:11-jre-slim
# Set the working directory in the container
EXPOSE 8080
WORKDIR /app
RUN adduser --system --group javauser
# Copy the built JAR file from the previous stage to the container
COPY --from=build /app/target/app-0.0.1-SNAPSHOT.jar .
RUN chown -R javauser:javauser /app
USER javauser
# Set the command to run the application
CMD ["java", "-jar", "app-0.0.1-SNAPSHOT.jar"]