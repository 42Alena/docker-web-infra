# [https://www.debian.org/releases/]: "13 	Trixie 	2025-08-09 	Current "stable" release"
FROM debian:bookworm

# Install required packages
RUN apt-get update && \
    apt-get install -y nginx openssl ca-certificates curl && \
    rm -rf /var/lib/apt/lists/*

# Create SSL folder
RUN mkdir -p /etc/nginx/ssl

# Generate self-signed certificate for akurmyza.42.fr
RUN openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
    -keyout /etc/nginx/ssl/server.key \
    -out /etc/nginx/ssl/server.crt \
    -subj "/C=DE/ST=BE/L=Berlin/O=42/OU=Inception/CN=akurmyza.42.fr"

# Copy Nginx config
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Copy test index.html into WordPress root (for SSL test before WP ready)
COPY conf/index.html /var/www/wordpress/index.html

EXPOSE 443

# Run Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
