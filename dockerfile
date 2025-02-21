FROM dart:3.6

WORKDIR /app

# Copy pubspec files
COPY pubspec.* ./
# Get dependencies
COPY firebase_service.json ./


# Copy the rest of the application
RUN dart pub get

# Make sure the firebase_service.json file is copied
COPY . .

# Get dependencies again (if pubspec.yaml changed)
ENV PORT=8080

# Set environment variables
CMD ["dart", "lib/main.dart"]


# Expose the port
EXPOSE 8080