FROM debian:bullseye-slim

# Install dependencies
RUN apt-get update && apt-get install -y curl git unzip xz-utils zip libglu1-mesa wget

# Install Dart SDK
RUN apt-get update && apt-get install -y apt-transport-https
RUN wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list
RUN apt-get update && apt-get install -y dart

# Add Dart to PATH
ENV PATH="/usr/lib/dart/bin:${PATH}"

# Set the working directory
WORKDIR /app

# Copy the pubspec files first (for better caching)
COPY pubspec.yaml pubspec.lock* ./

# Try both Dart and Flutter commands - one will work depending on your project type
RUN dart pub get || true

# Copy the rest of the project
COPY . .

# Try Flutter pub get if dart pub get failed
RUN if [ ! -d ".dart_tool" ]; then apt-get update && apt-get install -y curl && \
    curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.3-stable.tar.xz && \
    tar xf flutter_linux_3.19.3-stable.tar.xz && \
    export PATH="$PATH:/app/flutter/bin" && \
    flutter pub get; fi

# Copy Firebase service account key
COPY firebase_service.json .

# Set environment variables
ENV PORT=8080

# Start the server
CMD ["dart", "lib/main.dart"]

EXPOSE 8080
