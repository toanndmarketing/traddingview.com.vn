FROM ghost:5.58.0-alpine

# Metadata
LABEL maintainer="TradingView Vietnam"
LABEL description="Ghost CMS for TradingView.com.vn with S3 storage adapter"

# Set working directory
WORKDIR /var/lib/ghost

# Copy package.json for S3 adapter
COPY package.json ./

# Install S3 storage adapter
RUN npm install --production && \
    npm cache clean --force

# Create adapters directory and copy S3 adapter
RUN mkdir -p content/adapters/storage && \
    cp -r node_modules/ghost-storage-adapter-s3 content/adapters/storage/s3

# Copy custom themes (if exists)
COPY content/themes ./content/themes 2>/dev/null || true

# Copy config file
COPY config.docker.json ./config.production.json

# Set proper permissions
RUN chown -R node:node /var/lib/ghost/content && \
    chmod -R 755 /var/lib/ghost/content

# Switch to node user for security
USER node

# Expose Ghost port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:3000 || exit 1

# Start Ghost
CMD ["node", "current/index.js"]

