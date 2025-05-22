# Slim down Docker image
> Here's a Dockerfile which builds my Go application. I used Ubuntu, because I know how to do that in Ubuntu, but I am sure there's a better way. Bear with me, I just learned Docker!

## Objective
Turn the image from 600+ MB to less than 3MB! 👀 Obviously it should still run!

## Check how heavy is the built image
If you built it as `docker-slimmed-down` you can use:
```plaintext
❯ docker images docker-slimmed-down
REPOSITORY               TAG       IMAGE ID       CREATED          SIZE
docker-slimmed-down      latest    687cd3c10c58   29 seconds ago   653MB
```