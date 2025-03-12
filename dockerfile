FROM dart:3.6

WORKDIR /app

# Copy pubspec file
COPY pubspec.yaml ./

# Create a minimal pubspec with only essential dependencies for backend
RUN cat > pubspec.yaml << 'EOL'
name: bbm_backend_dev
description: "BBM Backend Service"
version: 1.0.0+1

environment:
  sdk: ^3.6.2

dependencies:
  shelf: ^1.4.1
  shelf_router: ^1.1.4
  http_parser: ^4.0.2
  firebase_admin: ^0.3.0+1
  asn1lib: 1.5.8
  http: ^1.3.0

dev_dependencies:
  lints: ^4.0.0
EOL

# Install dependencies
RUN dart pub get

# Copy application code
COPY lib/ lib/

# Copy Firebase service account key
COPY firebase_service.json .

# Set environment variables
ENV PORT=8080

# Start the server
CMD ["dart", "lib/main.dart"]

EXPOSE 8080
