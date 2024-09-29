# Use a base image with Java
FROM openjdk:17-jdk-slim

# Set the working directory
WORKDIR /app

# Copy your source code
COPY . .

# Compile the Java files (assuming your main class is Main.java)
RUN javac src/main/java/com/example/Main.java

# Run the application (replace with your main class)
CMD ["java", "-cp", "src/main/java", "com.example.Main"]
