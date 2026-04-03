# Use OpenJDK base image
FROM openjdk:17-slim

# Set working directory
WORKDIR /app

# Copy the built jar
COPY target/myapp-1.0-SNAPSHOT.jar app.jar

# Expose the app port
EXPOSE 8080

# Run the app
ENTRYPOINT ["java","-jar","app.jar"]
