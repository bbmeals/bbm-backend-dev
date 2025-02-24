FROM dart:3.6

WORKDIR /app

# Copy necessary files
COPY lib/ lib/
COPY pubspec.* ./

# Get dependencies
RUN flutter pub get

# Make sure firebase_service.json is available
COPY firebase_service.json .

# Get dependencies again
RUN dart pub get --offline

# Set environment variables
ENV PORT=8080

# Start the server
CMD ["dart", "lib/main.dart"]

# Expose the port
EXPOSE 8080