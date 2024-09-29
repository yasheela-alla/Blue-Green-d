FROM eclipse-temurin:17-jdk-alpine

EXPOSE 8080

# Set the working directory in the container
ENV APP_HOME /usr/src/app
WORKDIR $APP_HOME

# Copy the source code into the container
COPY src/ $APP_HOME/src/

# Compile the Java files
RUN javac src/*.java

# Run the compiled Java program (replace MainClass with your actual main class)
CMD ["java", "src.MainClass"]
