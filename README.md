# HAWK local Keycloak server

This repository contains everything to get a local Keycloak server set up for development purposes.
The setup comes with a pre-configured realm and a user with admin rights. It also has the [hawk-auth-server](https://github.com/HAWK-Digital-Environments/hawk-keycloak-auth-server) extension already installed
and is ready to be used with the [hawk-auth-client](https://github.com/HAWK-Digital-Environments/hawk-auth-client) library.

## Starting the server

To start the server, simply run the following command:

```bash
docker compose up
``` 

The first start will take a while, as the container has to be built and the realm has to be imported. Subsequent starts will be much faster.
After the initial import is done, the changes you do to the realm will be persisted until you remove the mysql storage volume.

## Accessing the server

The server will be available on `http://localhost:8088` and can be accessed as user `admin` with password `password`.

## Usage in your docker compose

After you launched the server, the `keycloak_hawk_net` network will be available to be used by other services.
You can use the network in your own docker-compose file like this:

```yaml
services:
  my-service:
    image: my-service
    networks:
      - keycloak_hawk_net
      - default
networks:
  keycloak_hawk_net:
    name: keycloak_hawk_net
    external: true
```

After you adjusted your service, it will be able to access the keycloak server on the hostname `keycloak.hawk.docker`.

## Default realm (dev)

The default realm is called `dev` and comes preconfigured with a list of random users, groups, roles and 
a default client. 

All users have the password set to the same value as their username.
The sole exception is the "admin" user, which has the password `password`.
The admin user can be used as a superuser to manage the realm and the users.

## Default client (hawk)

There is also a default client called `hawk` that is pre-configured to work with the `hawk-auth-client` library.
To connect with it use the following settings:

- publicKeycloakUrl: `http://localhost:8088`
- realm: `dev`
- clientId: `hawk`
- clientSecret: `RHQjrfnuMcYDJqepveiGNDH45ZtpFrLv`
- internalKeycloakUrl: `http://keycloak.hawk.docker:8080` (use this when connecting from another docker container)

## Restoring the factory settings

You can always drop the server and restart it with the default realm by running the following command:

```bash
docker compose down -v && docker compose up
```

## Scripts

### User import
In the `bin/import-users.sh` file you can find a [modified clone of an existing script](https://github.com/UKHomeOffice/keycloak-utils/blob/master/import-users.sh)
to import users based on a csv file. In the `data/users.csv` file you can find an example of how the csv file should look like.
To trigger the import you can run the following command:

```bash
./bin/import-users.sh --import=./data/users.csv
```

## Using a local version of [hawk-auth-server](https://github.com/HAWK-Digital-Environments/hawk-keycloak-auth-server)
While developing the `hawk-auth-server` extension, you might want to use a local version of it in the keycloak server.
To do so create a new file called `docker-compose.override.yml` in the root of this repository and add the following content:

```yaml
services:
  keycloak:
    build:
      target: local_ext_dev
      additional_contexts:
        extension: /path/to/extension/directory
```

**IMPORTANT** Replace `/path/to/extension/directory` with the path to the `target` directory of the `hawk-auth-server` extension.
The `target` directory, is the build directory of the extension, which contains the `hawk-auth-server-extension.jar` file.

After adding the file simply (re)start your project using: `docker compose up --build`

## BEWARE

**This is a development setup and should not be used in production!**
