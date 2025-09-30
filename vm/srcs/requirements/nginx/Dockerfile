FROM debian:bookworm

# Install Nginx + TLS tooling
RUN apt-get update && \
    apt-get install -y --no-install-recommends nginx openssl ca-certificates curl && \
    rm -rf /var/lib/apt/lists/*

# Create SSL dir
RUN mkdir -p /etc/nginx/ssl

# Self-signed cert for akurmyza.42.fr (valid 365 days)
RUN openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
    -keyout /etc/nginx/ssl/server.key \
    -out /etc/nginx/ssl/server.crt \
    -subj "/C=DE/ST=BE/L=Berlin/O=42/OU=Inception/CN=akurmyza.42.fr"

# Copy config
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Optional: starter index for early HTTPS test (before WP ready)
RUN mkdir -p /var/www/wordpress
COPY conf/index.html /var/www/wordpress/index.html

EXPOSE 443
CMD ["nginx", "-g", "daemon off;"]
