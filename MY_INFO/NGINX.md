Manage SSL/TLS encryption so connections use https:// instead of http://.
in Inception you’re expected to serve your WordPress site through NGINX over

https://nginx.org/
nginx

nginx ("engin
https://nginx.org/en/download.html
https://nginx.org/en/docs/stream/ngx_stream_ssl_module.html


# RUN apt-get install -y nginx openssl ca-certificates curl
	apt-get install → command to install packages.
	-y → auto-answer “yes” (so Docker build doesn’t hang).
	nginx → the web server.
	openssl → tool to generate self-signed TLS certificate.
	ca-certificates → trusted root CAs (important for secure HTTPS).
	curl → simple HTTP client (to test inside the container).

# RUN apt-get install -y nginx openssl ca-certificates curl
	apt-get install → command to install packages.
	-y → auto-answer “yes” (so Docker build doesn’t hang).
	nginx → the web server
	openssl → tool to generate self-signed TLS certificate.
	ca-certificates → trusted root CAs (important for secure HTTPS).
	curl → simple HTTP client (to test inside the container).
	
# TEST(from folder with Dockerfile):
		docker build -t nginx .
		docker run --rm -it nginx bash
		inside container:
			nginx -v
			openssl version
			curl --version

# Create TLS certificate
	Subject: “Ensure SSL/TLS certificate is used, TLSv1.2 or TLSv1.3 only”
	Without certificate, NGINX cannot serve HTTPS on port 443.
	We use openssl req -x509 ... command to generate a self-signed cert automatically at build time

# RUN mkdir -p /etc/nginx/ssl
	Why /etc/nginx/ssl?
		/etc/ = standard place for configuration files in Linux.
		/etc/nginx/ = NGINX’s default config directory.
		ssl/ = we make a subfolder where we’ll store our certificate + private key.

# RUN openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
    -keyout /etc/nginx/ssl/server.key \
    -out /etc/nginx/ssl/server.crt \
    -subj "/C=DE/ST=BE/L=Berlin/O=42/OU=Inception/CN=localhost"
	[] explain:
		https://tracker.debian.org/pkg/openssl
		https://github.com/openssl/openssl 
		openssl → the OpenSSL tool. Secure Sockets Layer
		req → command to create or process certificate requests
		-x509 → output a self-signed X.509 certificate (instead of a CSR).
		-nodes → no password on private key (otherwise Docker build would stop asking you to type it).
		-newkey rsa:2048 → generate a new 2048-bit RSA key.
		-days 365 → certificate validity (1 year).
		-keyout → where to save private key file.
		-out → where to save certificate file.
		-subj → fills subject info without prompting interactively:
		/C=DE → Country = Germany
		/ST=BE → State = Berlin
		/L=Berlin → Locality = Berlin
		/O=42 → Organization = 42
		/OU=Inception → Organizational Unit
		/CN=localhost → Common Name (domain, later replace with login.42.fr)

# TEST:
		docker build -t nginx srcs/requirements/nginx
		docker run --rm -it nginx bash
		ls -l /etc/nginx/ssl	
			total 8
			-rw-r--r-- 1 root root 1318 Sep 11 17:04 server.crt
			-rw------- 1 root root 1704 Sep 11 17:04 server.ke

# HTML
	COPY conf/nginx.conf /etc/nginx/nginx.conf
	COPY conf/index.html /var/www/html/index.html



# OPENSSL
	
	RUN openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
    -keyout /etc/nginx/ssl/server.key \
    -out /etc/nginx/ssl/server.crt \
    -subj "/C=DE/ST=BE/L=Berlin/O=42/OU=Inception/CN=localhost"
	

# SSL script in /nginx/conf/nginxconf
	events {}

	http {
		include       /etc/nginx/mime.types;
		default_type  application/octet-stream;

		server {
			listen              443 ssl;               # only HTTPS
			ssl_protocols       TLSv1.2 TLSv1.3;       # required by subject
			ssl_certificate     /etc/nginx/ssl/server.crt;
			ssl_certificate_key /etc/nginx/ssl/server.key;

			server_name localhost;                     # later we’ll switch to login.42.fr
			root /var/www/html;
			index index.html;
		}
	}



# EXPOSE 443
	CMD ["nginx", "-g", "daemon off;"]
	EXPOSE 443 = documents that container listens on port 443.
	CMD = run nginx as PID 1 in foreground (no hacks like tail -f). Required by subject

[]test:
	docker build -t nginx srcs/requirements/nginx
	
	[]   Run container with port mapping:-p 443:443 = map 		host port 443 → container port 443. -->
			docker run --rm -p 443:443 nginx
	  		-p 443:443 = map host port 443 → container port 443.

	[] In another terminal, test: 
		curl -kI https://localhost
		-k = ignore self-signed cert warning.
		-I = HEAD request (headers only).
				see: HTTP/1.1 200 OK.

		[]Open browser → https://localhost

[] CMD ["nginx", "-g", "daemon off;"]
	CMD = run nginx as PID 1 in foreground (no hacks like tail -f). Required by subject

## DOCER COMPOSE
https://docs.docker.com/compose/gettingstarted/
```
services:                         # All your containers (services) are declared under this section
  nginx:                          # First service = NGINX (reverse proxy with TLS)
    container_name: nginx         # Explicit runtime name for the container (shows up in `docker ps`)
    build:                        # How to build the Docker image for this service
      context: ./requirements/nginx   # Path to the folder where the Dockerfile + config files live
      dockerfile: Dockerfile          # Which Dockerfile to use (explicit, default is "Dockerfile")
    image: nginx                  # Name/tag of the image once built (must equal service name for eval)
    ports:                        # List of port mappings host ↔ container
      - "443:443"                 # Expose port 443 on host → 443 in container (HTTPS only, required by subject)
    restart: on-failure           # Auto-restart container if it crashes (mandatory rule)
    networks:                     # List of user-defined networks this service belongs to
      - inception                 # Attach nginx to the "inception" bridge network (declared below)

  # mariadb:                      # Placeholder for MariaDB service (will be filled later)
  # wordpress:                    # Placeholder for WordPress service (will be filled later)

networks:                         # Global network definitions (outside services block)
  inception:                      # Define a network called "inception"
    driver: bridge                # Use the "bridge" driver (isolated network, containers talk by name)
```
🔑 Key reminders for defense

- Why build:? → Because you must build your own images from Dockerfiles, not pull them from DockerHub

- Why image: nginx? → Image name must be the same as service name; otherwise, it’s a fail

- Why only "443:443"? → The subject requires HTTPS (TLS v1.2/v1.3) and forbids exposing port 80

- Why restart: on-failure? → Containers must auto-restart after crash

- Why networks:? → You need a custom bridge network (not host, not links)

# Test from host (other terminal)
	curl -kI https://localhost

- -k = ignore self-signed cert warning.
- -I = HEAD request (only headers).
# Test in braowser : open:
   https://localhost
