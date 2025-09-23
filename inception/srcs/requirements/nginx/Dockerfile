# [https://www.debian.org/releases/]: "13 	Trixie 	2025-08-09 	Current "stable" release"
FROM debian:bookworm

RUN apt-get update -y && apt-get upgrade -y 

RUN apt-get install -y nginx openssl ca-certificates curl

RUN mkdir -p /etc/nginx/ssl

# https://wiki.openssl.org/index.php/Compilation_and_Installation
RUN openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
    -keyout /etc/nginx/ssl/server.key \
    -out /etc/nginx/ssl/server.crt \
    -subj "/C=DE/ST=BE/L=Berlin/O=42/OU=Inception/CN=localhost"

# Copy my Nginx config (server block) into container
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Copy static index file (only for test before wordpress: if Nginx + SSL works by opening https://login.42.fr and seeing this page)
COPY conf/index.html /var/www/html/index.html

EXPOSE 443
# Docker to run NGINX in foreground
CMD ["nginx", "-g", "daemon off;"]