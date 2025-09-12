# Compose works from the folder where your docker-compose.yml is (that’s in srcs/).
	build:
      context: ./requirements/nginx 
docker compose run from where .yml is in ./src
=> then start is./ and not ./src 
# Validate the config
	docker compose config
This checks YAML syntax.
If indentation is wrong → error.
If correct → it prints the full expanded config.

# Build the image
	docker compose build 
	#special service inside compose
	docker compose build nginx
Reads services: nginx → builds your NGINX image from ./srcs/requirements/nginx/Dockerfile.

Tags the image as nginx.

# Run container
```
	docker compose up -d
```
- up = start all defined services.

- -d = detached (in background).

Only nginx will start now (MariaDB/WordPress are empty, so Compose ignores them).	

# Check running containers
	docker compose ps
# See logs
	docker compose logs -f nginx
-f = follow logs live.
Useful if nginx crashes at startup.

# Stop everything
	docker compose down
Stops and removes containers, but not images.

