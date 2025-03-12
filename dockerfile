FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y curl git unzip xz-utils zip libglu1-mesa

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /flutter
ENV PATH="/flutter/bin:${PATH}"

# Set the working directory
WORKDIR /app

# Copy the entire project
COPY . .

# Install dependencies
RUN flutter pub get

# Copy Firebase service account key
COPY firebase_service.json .

# Set environment variables
ENV PORT=8080

# Start the server
CMD ["dart", "lib/main.dart"]

EXPOSE 8080
