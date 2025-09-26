Set environment variables within your container's environment
- https://docs.docker.com/compose/how-tos/environment-variables/set-environment-variables/

Tip
* Don't use environment variables to pass sensitive information, such as passwords, in to your containers. Use secrets instead.


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


#  IF not created folder yet =>  create the data folders on your host:
(In the school VM you’ll switch to /home/<login>/data/... — but on macOS, /Users/... is correct.)

`mkdir -p ~/data/mariadb`

`mkdir -p ~/data/wordpress`

On macOS, this expands to /Users/alenakurmyza/data/....
in Docker compose:
```
	volumes:
	...   

	   # --- Use this on your Mac ---
      device: /Users/alenakurmyza/data/mariadb
      # --- Use this at School VM ---
      # device: /home/akurmyza/data/mariadb
```
### Then rebuild and run again
```
docker compose down -v                # clean old containers + volumes
docker compose up -d mariadb
```



# USe environment .env for passwords:

## environment: with ${VAR}
```bash
environment:
  DB_NAME: ${DB_NAME}
  DB_USER: ${DB_USER}
```
Lets you explicitly control which vars are passed.

Useful if .env has extra vars you don’t want inside the container.

More verbose, easy to make mistakes.

To be safe, always define the variable in .env.

```bash
env_file:
  - .env
```
Loads all variables from .env into the container.

Easiest and matches the subject’s recommended practice

--
## Syntax : -inception vs [inception]
…it means this service is attached to the network named inception.
Internally Compose expects a list ([]) of network names, because a service can belong to multiple networks:

networks: [inception]       # compact form = exactly same
networks:
  - inception               # long form (what you already use)

- inception

    The dash - means “this is a list item”.

    Each line under networks: is one item.
Inline (flow style list, in [ ])
networks: [inception]
The square brackets mean “list in inline style”.

Same as above, but compact in one line.

👉 Both forms are valid YAML, produce the same result, and Docker Compose treats them the same.
It’s purely a style choice.