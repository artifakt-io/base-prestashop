
## Informations générales
***
Vous trouverez dans ce repository un package qui vous permettra d'installer prestashop en local  pour prestashop avec :
Il est également destinné à être deployé sur les environnements Artifakt.

Pour ce faire il suffit de prendre l'ensemble des dossiers/fichiers et de les déposer à la racine de votre projet versionné.

Ce package est prévu pour fonctionner en local sur des architecture de type amd64 et/ou arm64 (puce M1 sur les Mac les plus récents).

La version de base est configuré sur de l'amd64, plus étendue.

Les commentaires laissés dans le docker-compose.yml sont assez clairs pour basculer sur de l'arm.

En ce qui concerne mysql et toujours dans un contexte local sur de l'arm64, il a fallu utiliser un repository custom afin de mettre en place la version 5.7 ([liupeng0518/mysql:5.7-arm64](https://hub.docker.com/layers/liupeng0518/mysql/5.7-arm64/images/sha256-2977a58e24e79d9bcb2153a6c0ff2fb66dce5a57fc3622663bf37c38c7fd6333?context=explore))

### Versions disponible
* prestashop 1.7.8.7 sur la branche [**prestashop-1.7.8.7**](https://github.com/artifakt-io/base-prestashop/tree/prestashop-1.7.8.7)) 
## Installation
***
L'installation en local se lance par:
```
docker-compose up --build  -d
```

## Package Artifakt
***
Le package se compose:
* Du dossier .artifakt
    * Du dossier apache/certs (certificats en local)
    * Du dossier etc (permet de surcharger la configuration des services)
        * mysql
        * nginx 
        * nginx-proxy
        * php
        * varnish 
    * build.sh
    * composer_setup.sh
    * entrypoint.sh
* .dockerignore
* .gitignore
* artifakt-custom-build-args
* docker-compose.yml
* Dockerfile
* README.md  
## Commandes docker courantes
***

| Commandes | Description |
|:--------------|:-------------|
| docker ps | Visualiser les conteneurs actifs |
| docker ps -a  | Visualiser tous les conteneurs|
| docker stop CONTAINER ID | Arrêter un conteneur |
| docker start CONTAINER ID | Démarrer un conteneur |
| docker images | Lister les images existantes |
| docker exec -t -i CONTAINER ID /bin/bash | Exécuter des commandes dans un conteneur actif |
| docker inspect CONTAINER ID | Inspecter la configuration d'un conteneur |
| docker logs -ft CONTAINER ID | Visualiser les logs d'un conteneur |

