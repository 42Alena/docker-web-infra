https://docs.docker.com/compose/how-tos/environment-variables/set-environment-variables/

Put all secrets in srcs/.env

real .env put in .gitignore=> never push original passw to git

# in   docker-compose.yml for each service:

```bash
env_file: ./srcs/.env
```

Docker Compose will automatically read and inject all variables from that file into the container environments. You don’t need to repeat them with environment: unless you want to override or limit which ones are passed.

# 2.Variant 
https://docs.docker.com/compose/how-tos/environment-variables/set-environment-variables/

https://docs.docker.com/engine/swarm/secrets/

Tip

Don't use environment variables to pass sensitive information, such as passwords, in to your containers. Use secrets instead.