FROM dart:3.6

WORKDIR /app

# Copy entire project
COPY . .

# Remove potentially problematic dependency
RUN sed -i '/firebase_core:/d' pubspec.yaml

# Install dependencies
RUN dart pub get

# Set environment variables
ENV PORT=8080

# Start the server
CMD ["dart", "lib/main.dart"]

EXPOSE 8080
