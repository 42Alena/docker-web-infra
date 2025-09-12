


# INFO SSL:
		https://wiki.openssl.org/index.php/Compilation_and_Installation
		https://nginx.org/en/docs/http/configuring_https_servers.html
        https://nginx.org/en/docs/stream/ngx_stream_ssl_module.html
        https://hub.docker.com/_/nginx

Manage SSL/TLS encryption so connections use https:// instead of http://.
explian.



# HTTP vs HTTPS

    http:// = HyperText Transfer Protocol. Plain text, not secure.

    https:// = HTTP Secure. Same protocol, but encrypted with SSL/TLS.

# SSL

    Secure Sockets Layer.

    An old protocol (from Netscape, 1995) to secure connections.

    Versions: SSLv2 (1995), SSLv3 (1996). Both now obsolete.

# TLS

    Transport Layer Security.

    Modern replacement for SSL (introduced in 1999).

    Provides:

        🔒 Encryption (no one can read your data)

        🆔 Authentication (server proves its identity)

        🛡 Integrity (data not modified in transit)

# Certificates

    A certificate is like a digital ID card for your server.

    In Inception, you’ll create a self-signed certificate with openssl.

    Browsers will warn “⚠️ not trusted,” but that’s okay for the project.

# Port 80 vs Port 443

    Port 80 = HTTP (insecure). Forbidden in Inception.

    Port 443 = HTTPS (secure). Must be the only entry.
# @Task must manage SSL/TLS encryption.
    @Task Your NGINX container must be the only entry point, listening only on port 443 (the HTTPS port).

    @Task You must use TLSv1.2 or TLSv1.3.

    @Task Access via http://login.42.fr must fail, and only https://login.42.fr should work

    @Task: Subject = requires HTTPS with TLS.
    You must set up NGINX with TLSv1.2 or TLSv1.3 only


📌 In short
    Yes, you must configure HTTPS with SSL/TLS in Inception.
    HTTP access (:80) must be blocked.
    You generate a self-signed TLS certificate with OpenSSL inside the NGINX container.
    NGINX is configured to use listen 443 ssl; with your .crt and .key files.
    During defense, evaluator will check:
        http://login.42.fr → ❌ blocked
        https://login.42.fr → ✅ loads WordPress site


#  .gitignore and secrets:

    Don’t commit real credentials; keep examples like .env.example with placeholders, and ignore the real .env. The subject explicitly warns about credentials in git.

## Dockerfile
	RUN openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
    -keyout /etc/nginx/ssl/server.key \
    -out /etc/nginx/ssl/server.crt \
    -subj "/C=DE/ST=BE/L=Berlin/O=42/OU=Inception/CN=localhost"
	
 Each part means:
     openssl → the main tool for cryptography.
    req → request a certificate.
    -x509 → create a self-signed certificate (not a certificate request for a CA).
    -nodes → “no DES”: don’t encrypt the private key with a password (needed for automation).
    -out <file> → where to save the certificate file (.crt).
    -keyout <file> → where to save the private key (.key).
    -subj → pre-fill subject fields (so Docker doesn’t hang asking questions).

    -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=login.42.fr":
        C=FR → Country = France
            ST=IDF → State = Île-de-France
                L=Paris → Locality = Paris
                O=42 → Organization = 42
                    OU=42 → Organizational Unit = 42
        CN=login.42.fr → Common Name = your domain (e.g., akurmyza.42.fr)

