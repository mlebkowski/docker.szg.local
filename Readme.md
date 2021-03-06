# Syzygy local dev environment

 * [Traefik](https://traefik.szg.dev)
 * [Consul](https://consul.szg.dev)
 * [Mailhog](https://mailhog.szg.dev)
 * [Portainer](https://portainer.szg.dev)

## Instalation

1. Make sure you have installed:
  * Docker for Mac
  *`jq` (`brew install jq`)
2. Add `bin/` to your path
3. run `make`

## Services

 * Mysql: `docker.for.mac.localhost:3306` or `localhost:3306`
 * Redis: `docker.for.mac.localhost:6379` or `localhost:6379`
 * Elasticsearch 1.7: `docker.for.mac.localhost:9200` or `elasticsearch.dev`
 * SMTP server (mailhog): `docker.for.mac.localhost:1025` or `localhost:1025`

## Run one-off in docker

```
run-in-docker php -v
```

The command will preserve the current working dir relative to the project root, and choose the best image
basing on the command you want to invoke (see `io.szg.dev.commands` label below)


## Start your project with all dependencies

```
start-in-docker
```

This simple wrapper on `docker-compose` is best suited for the first run:

 * it installs all of the dependencies
 * makes sure that the infrastructure project is running
 * runs mutagen or other daemons if need be
 * etc

## Expose your local environment 

`brew install envchain` is strongly adviced for your convenience.

```bash
# in local network:
expose-internal www.name-of-your-project.dev [optional custom name]
```

You will need `$DIGITALOCEAN_API_KEY` to update the DNS records during the first run. 

```bash
# publicly:
expose-public www.name-of-your-project.dev [optional custom name]
```

This needs to have a localtunnel endpoint URL in `$LOCALTUNNEL_URL` variable.

## Default `docker-compose.yml` in your project

```
version: "3"
services:
    # Your main service to start:
    www: 
        # use your custom Dockerfile, but hide it in a subdirectory, so you don’t have a large build context
        build: .docker/
        # remember to bind your services to a public interface
        command: bin/console server:run 0.0.0.0:80
        working_dir: /app
        volumes:
            # :delegated strategy improves performance
            - ./:/app:delegated
            # yay, a shared composer cache & settings!
            - composer:/home/composer
        environment:
            # this is needed for the shared cache to work
            COMPOSER_HOME: /home/composer
        labels:
            # use this container for running those commands by default:
            io.szg.dev.commands: php composer

    browsersync:
        build: .docker/
        command: gulp browsersync
        working_dir: /app
        environment:
          BACKEND_URL: "http://backend"
          NPM_HOME: "/home/npm"
        links:
          - www:backend
        volumes:
            - ./:/app:delegated
            # shared npm cache
            - npm:/home/npm

# you need to attach to the default szg docker network
networks:
    default:
        external:
            name: szg_default

# also, you need to attach the shared cache volumes
volumes:
    composer:
        external:
            name: szg_composer
    npm:
        external:
            name: szg_npm
```
