# Table of Contents

- [General Information](#general-information)
- [Workflow](#workflow)
- [Installation](#installation)
- [Artifakt Package](#artifakt-package)
- [Clean Reinstall](#clean-reinstall)
- [Variables](#variables)
- [Common Docker Commands](#common-docker-commands)

## General Information

In this repository, you will find a package that allows you to install Prestashop locally for Prestashop 1.7.8.7 with:

- php 7.4-fpm
- varnish
- mysql 5.7

It is also intended to be deployed on Artifakt environments.

To do this, simply take all the folders/files and drop them at the root of your versioned project.

This package is designed to work locally on amd64 and/or arm64 architectures (M1 chip on the latest Macs).

The base version (docker-compose.yml) is configured for amd64, but it can be extended.

As for mysql and still in a local context on arm64, a custom repository had to be used to set up version 5.7 (liupeng0518/mysql:5.7-arm64).

```

```

## Workflow

Here is the explanation of the workflow locally and from the Artifakt console.

### Local

Locally, the deployment follows a common logic. It is based on the Dockerfile and docker-compose.yml to set up the development environment. In order to simulate the console behavior, it is necessary to configure the "artifakt-custom-build-args" and ".env" files.

artifakt-custom-build-args is necessary to access the different variables during the construction of the application image (see the call to the composer_setup.sh script in the Dockerfile). .env is necessary to access the different variables during the deployment of the application container (see usage in entrypoint.sh).

### Artifakt Console

On the console, the files .env, artifakt-custom-build-args, and docker-compose.yml are not used during deployment. Only the Dockerfile can be used, provided the environment is configured accordingly in the Settings &gt; Build &amp; Deploy menu of the environment (Use your own Runtime).

The workflow is divided into two parts, Build and Deploy.

```

```

## Installation

To install, simply download all the folders/files and place them at the root of your versioned project.

```

```

## Artifakt Package

In this repository, you will find a package that allows you to install Prestashop locally for Prestashop 1.7.8.7 with:

- php 7.4-fpm
- varnish
- mysql 5.7

It is also intended to be deployed on Artifakt environments.

To do this, simply take all the folders/files and drop them at the root of your versioned project.

This package is designed to work locally on amd64 and/or arm64 architectures (M1 chip on the latest Macs).

The base version (docker-compose.yml) is configured for amd64, but it can be extended.

As for mysql and still in a local context on arm64, a custom repository had to be used to set up version 5.7 (liupeng0518/mysql:5.7-arm64).

```

```

## Clean Reinstall

To perform a clean reinstall, simply remove all containers and volumes related to the project.

```

```

## Variables

---

| Variables                                                     | Description                                    |
| :------------------------------------------------------------ | :--------------------------------------------- |
| LOCAL_INSTALL                                                 | Actions specific to local development          |
| <span style="color: #FF0000">PRESTASHOP_VERSION</span>        | Prestashop version (mandatory)                 |
| <span style="color: #FF0000">PRESTASHOP_SERVER_DOMAIN</span>  | Server domain information (mandatory)          |
| <span style="color: #26B260">PRESTASHOP_PROJECT_NAME</span>   | Project name (mandatory at setup)              |
| PRESTASHOP_CLEAN_REINSTALL                                    | Reinstall the project                          |
| <span style="color: #FF0000">ARTIFAKT_COMPOSER_VERSION</span> | (mandatory)                                    |
| PRESTASHOP_ADMIN_PATH                                         | Default value: admin_base (mandatory at setup) |

## Common Docker commands

---

| Command                                  | Description                              |
| :--------------------------------------- | :--------------------------------------- |
| docker ps                                | View active containers                   |
| docker ps -a                             | View all containers                      |
| docker stop CONTAINER ID                 | Stop a container                         |
| docker start CONTAINER ID                | Start a container                        |
| docker images                            | List existing images                     |
| docker exec -t -i CONTAINER ID /bin/bash | Execute commands in an active container  |
| docker inspect CONTAINER ID              | Inspect the configuration of a container |
| docker logs -ft CONTAINER ID             | View the logs of a container             |
