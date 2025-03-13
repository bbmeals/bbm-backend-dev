FROM dart:3.6

WORKDIR /app

# Copy entire project
COPY . .

# Remove Firebase Remote Config dependency
RUN sed -i '/firebase_remote_config:/d' pubspec.yaml

# Install dependencies
RUN dart pub get

# Set environment variables
ENV PORT=8080

# Start the server
CMD ["dart", "lib/main.dart"]

EXPOSE 8080
