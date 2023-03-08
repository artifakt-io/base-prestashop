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

As for mysql and still in a local context on arm64, a custom repository had to be used to set up version 5.7 ([liupeng0518/mysql:5.7-arm64](https://hub.docker.com/layers/liupeng0518/mysql/5.7-arm64/images/sha256-2977a58e24e79d9bcb2153a6c0ff2fb66dce5a57fc3622663bf37c38c7fd6333?context=explore)).

## Workflow

Here is the explanation of the workflow locally and from the Artifakt console.

### **Local**

In local, the deployment follows a common logic. It is based on the Dockerfile and docker-compose.yml to set up the development environment. To simulate the behavior of the console, it is necessary to configure the "artifakt-custom-build-args" and ".env" files.

- **artifakt-custom-build-args** is necessary to access the various variables during the construction of the application image (see the call to the composer_setup.sh script in the Dockerfile).
- **.env** is necessary to access the various variables during the deployment of the application container (see usage in entrypoint.sh).

### Artifakt Console

On the console, the files .env, artifakt-custom-build-args, and docker-compose.yml are not used during deployment. Only the Dockerfile can be used, provided the environment is configured accordingly in the Settings &gt; Build &amp; Deploy menu of the environment (_Use your own Runtime_).

The workflow is divided into two parts, **Build** and **Deploy**.

### Build

---

The build process uses the Dockerfile (custom or native) and the native Artifakt docker-compose.yml to build the project's image and then deposit it on a private registry on GCP (Google Cloud Platform).

To be able to add actions during this process, we have set up a **build.sh** file that allows us to override the base registry (see "FROM" in the Dockerfile) and the Dockerfile itself.

In this context, and only within the "RUN" command, the build process can access the environment variables configured in the Artifakt console.

The base runtime image (see "FROM" in the Dockerfile) calls a script (docker-entrypoint.sh) that is responsible for executing the **entrypoint.sh** script.

Here are the details of the image used for this PrestaShop application ([artifakt-php-7.4-fpm](https://github.com/artifakt-io/artifakt-docker-images/tree/main/php/7.4-fpm)).

### Deploy

---

When we talk about deployment, we mean using the previously created build.

The containers are set up and this is the moment when we can inject modifications into the application container.

The environment variables are accessible. It is the **entrypoint.sh** script here that takes care of all the actions.

## Installation

---

The local installation can be launched by:

```
docker-compose up -d

```

or for ARM architecture:

```
docker-compose -f docker-compose-arm.yml up -d

```

In the Artifakt console, we talk about jobs. The most used ones are:

- **Deploy**: Redeploys the containers (in case of variable changes, for example)
- **Build &amp; deploy**: Rebuilds the image and redeploy the containers.

This package provides local access to the site at **https://localhost** and to the back office at **https://localhost/admin_base**

- Email address: _(to be modified)_
- Password: 0123456789 _(to be modified)_

## Artifakt Package

---

The Artifakt package is composed of:

- The .artifakt folder
  - The apache/certs folder (local certificates)
  - The etc folder (allows overriding the configuration of services)
    - mysql
    - nginx
    - nginx-proxy
    - php
    - redis
    - varnish
  - build.sh
  - composer_setup.sh
  - entrypoint.sh
  - clean_reinstall.sh
- .dockerignore
- .gitignore
- artifakt-custom-build-args
- docker-compose.yml
- docker-compose-arm.yml
- Dockerfile
- README.md

## Clean Reinstall

---

If you want to reset the installation, simply set the PRESTASHOP_CLEAN_REINSTALL=1 variable either:

- In the .env file locally
- In the Artifakt console during a build and deploy. &lt;span style="color: #FF0000"&gt;Note that this variable should be temporary and only for a specific job.&lt;/span&gt;

## Variables

---

| Variables                                                    | Description                           |
| :----------------------------------------------------------- | :------------------------------------ |
| LOCAL_INSTALL                                                | Actions specific to local development |
| PRESTASHOP_VERSION                                           | Default Prestashop version (1.7.8.8)  |
| <span style="color: #FF0000">PRESTASHOP_SERVER_DOMAIN</span> | Server domain information (mandatory) |
| <span style="color: #26B260">PRESTASHOP_PROJECT_NAME</span>  | Project name (mandatory at setup)     |
| PRESTASHOP_CLEAN_REINSTALL                                   | Reinstall the project                 |
| ARTIFAKT_COMPOSER_VERSION                                    | (2.3.7 by default)                    |
| PRESTASHOP_ADMIN_PATH                                        | Default value: admin_base             |

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
