FROM alpine:3.19

# Install dependencies
RUN apk add --no-cache \
    bash \
    curl \
    docker-cli \
    procps \
    coreutils \
    grep \
    sed \
    gawk \
    fail2ban

# Create working directory
WORKDIR /app

# Copy monitor script
COPY monitor.sh /app/monitor.sh
RUN chmod +x /app/monitor.sh

# Run monitor every 5 minutes
CMD ["sh", "-c", "while true; do /app/monitor.sh; sleep 300; done"]
