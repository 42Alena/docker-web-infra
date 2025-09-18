## Dockerized Web Infrastructure – Nginx, MariaDB, WordPress


🚀 A complete web stack built with Docker as part of the **42 Inception project**.  
This repository sets up a production-like environment using containers:

- **Nginx** – Reverse proxy & HTTPS termination  
- **MariaDB** – Relational database for WordPress  
- **WordPress** – CMS running with PHP-FPM  
- **Docker Compose** – Infrastructure orchestration  

### Features
- Containerized web services for isolation & portability  
- Secure HTTPS support with TLS certificates  
- Persistent database & WordPress data (volumes)  
- Configurable environment variables via `.env`  

### How to run
```bash
make        # Build and start containers
make down   # Stop containers (data preserved)
make clean  # Remove containers and volumes (fresh start)
```

The file srcs/.env is provided with placeholders for evaluation.
For local testing, copy srcs/.env.local → srcs/.env.
