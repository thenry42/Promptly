# Build the Flutter application
FROM debian:bullseye

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    libglu1-mesa \
    wget \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /flutter
ENV PATH="/flutter/bin:${PATH}"

# Set the Flutter version to stable
RUN flutter channel stable
RUN flutter upgrade
RUN flutter config --enable-web

# Copy the Flutter app to the container
WORKDIR /app
COPY frontend/promptly_app .

# Get Flutter dependencies
RUN flutter pub get

# Install additional dependencies if needed
# RUN flutter pub add http

# Set entrypoint to flutter
ENTRYPOINT ["flutter"]

# Default command runs the app in development mode
CMD ["run", "--web-port", "8080", "--web-hostname", "0.0.0.0"]