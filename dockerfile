FROM dart:3.6

WORKDIR /app

# Copy the entire project
COPY . .

# Get dependencies
RUN dart pub get

# Copy Firebase service account key
COPY firebase_service.json .

# Set environment variables
ENV PORT=8080

# Start the server
CMD ["dart", "lib/main.dart"]

EXPOSE 8080