# Multi-stage-build

# Stage1: Build the JAR using Maven
FROM maven:3.8.4-openjdk-17 AS build

# Set working directory
WORKDIR /app

# Copy only pom.xml first to cache dependencies
COPY pom.xml .

# Download dependencies (this layer caches unless pom.xml changes)
RUN mvn dependency:go-offline

# Copy source code
COPY src ./src

#  Build the JAR
RUN mvn clean package -DskipTests

# Stage 2: Create final lightweight image

FROM openjdk:17-jre-slim

WORKDIR /app

## Copy the built JAR from the first stage
COPY --from=build /app/target/*.jar app.jar

# Expose port
EXPOSE 8082

#Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]

