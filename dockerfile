# Use the official Dart SDK image
FROM dart:3.6

WORKDIR /app

# Copy pubspec files first
COPY pubspec.* ./

# Get dependencies
RUN dart pub get

# Copy the rest of the application
COPY . .

# Make sure the firebase_service.json file is copied
COPY firebase_service.json .

# Get dependencies again
RUN dart pub get --offline

# Set environment variables
ENV PORT=8080

# Start the server
CMD ["dart", "lib/main.dart"]

# Expose the port
EXPOSE 8080