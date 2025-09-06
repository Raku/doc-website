# Stage 1: Build the documentation
FROM docker.io/rakudo-star:latest AS builder

# Install necessary system packages
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /build

# Copy the entire project
COPY . .

# Install Raku dependencies
RUN POD_RENDER_NO_HIGHLIGHTER=1 zef install . --deps-only

# Build the documentation site
RUN ./bin_files/build-site --without-completion --no-status

# Build the EBook
RUN ./bin_files/build-site --no-status EBook

# Create the archive
RUN cd rendered_html && tar zcf ../raku-doc-website.tar.gz *

# Stage 2: Serve with Caddy
FROM docker.io/caddy:latest

# Add expiration label for Quay.io
ARG quay_expiration=8w
LABEL quay.expires-after=${quay_expiration}

# Copy the built static files from builder stage
COPY --from=builder /build/raku-doc-website.tar.gz /tmp/
RUN cd /usr/share/caddy && tar xzf /tmp/raku-doc-website.tar.gz && rm /tmp/raku-doc-website.tar.gz

# Copy Caddyfile
COPY Caddyfile /etc/caddy/Caddyfile

# Expose port 80
EXPOSE 80

# Run Caddy
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]

