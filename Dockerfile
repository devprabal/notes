FROM debian:bookworm-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    apt-transport-https \
    ca-certificates \
    git \
    make \
    zip \
    lowdown \
    && rm -rf /var/lib/apt/lists/*

# Add Google's GPG key and Dart repository (with arm64 support)
RUN wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/dart.gpg \
    && echo 'deb [signed-by=/usr/share/keyrings/dart.gpg arch=amd64,arm64] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main' | tee /etc/apt/sources.list.d/dart_stable.list

# Install Dart SDK and sass
RUN apt-get update && apt-get install -y dart sass && rm -rf /var/lib/apt/lists/*

# Set PATH for Dart
ENV PATH="/usr/lib/dart/bin:${PATH}"

WORKDIR /app
VOLUME ["/app"]
