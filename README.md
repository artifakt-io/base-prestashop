## Sommaire
1. [Informations générales](#informations-generales)
2. [Workflow](#workflow)
3. [Installation](#installation)
4. [Package Artifakt](#package-artifakt)
5. [Commandes docker courantes](#commandes-docker-courantes)

## Informations générales
***
Vous trouverez dans ce repository un package qui vous permettra d'installer prestashop en local pour prestashop 1.7.8.7 avec :

* php 7.4-fpm
* varnish
* mysql 5.7

Il est également destinné à être deployé sur les environnements Artifakt.

Pour ce faire il suffit de prendre l'ensemble des dossiers/fichiers et de les déposer à la racine de votre projet versionné.

Ce package est prévu pour fonctionner en local sur des architecture de type amd64 et/ou arm64 (puce M1 sur les Mac les plus récents).

La version de base (docker-compose.yml) est configuré sur de l'amd64, plus étendue.

En ce qui concerne mysql et toujours dans un contexte local sur de l'arm64, il a fallu utiliser un repository custom afin de mettre en place la version 5.7 ([liupeng0518/mysql:5.7-arm64](https://hub.docker.com/layers/liupeng0518/mysql/5.7-arm64/images/sha256-2977a58e24e79d9bcb2153a6c0ff2fb66dce5a57fc3622663bf37c38c7fd6333?context=explore))


## Workflow
***
Voici l'explication du worflow en local et depuis la console Artifakt.
### **Local**
En local Le déploiement suit une logique courante. Il se base sur le Dockerfile et le docker-compose.yml pour mettre en place l'environnement de développement.
Afin de simuler le comportement de la console, il est nécessaire de configurer les fichiers "artifakt-custom-build-args" et ".env".
* **artifakt-custom-build-args** est nécessaire pour avoir accès aux différentes variables lors de la construction de l'image applicative (cf. appel du script composer_setup.sh dans le Dockerfile).
* **.env** est nécessaire pour avoir accès aux différentes variables lors du déploiement du conteneur applicatif (cf. utilisation dans entrypoint.sh).

### **Console Artifakt**
Sur la console les fichiers **.env**, **artifakt-custom-build-args** et **docker-compose.yml** ne sont pas utilisés lors du déploiement.
Seul le Dockerfile peut l'être à condition de configurer l'environnement en fonction dans le menu Settings > Build & deploy de l'environnement (_Use your own Runtime_).

Le workflow se déroule en deux parties, le **Build** et le **Deploy**.
### Build
***
Le build va utiliser le Dockerfile (custom ou natif) et le docker-compose.yml natif d'Artifakt pour construire l'image du projet et là déposer sur un registry privé sur GCP (Google cloud platform).

Afin de pouvoir ajouter des actions à ce moment nous avons mis en place un fichier **build.sh** afin de pouvoir surcharger le registry de base (voir "FROM" dans le Dockerfile) et le Dockerfile lui même.

Dans ce contexte et seulement dans le cadre de la commande "RUN", le build peut accéder aux variables d'environnement configurer dans la console Artifakt.

L'image de base du runtime (voir "FROM" dans le Dockerfile) appel un script (docker-entrypoint.sh) qui sera chargé de lancer l'exécution du script **entrypoint.sh**

Voici le détail de l'image utilisée pour ce prestashop ([artifakt-php-7.4-fpm](https://github.com/artifakt-io/artifakt-docker-images/tree/main/php/7.4-fpm))

### Deploy
***
Lorsque l'on parle de deploy, il s'agit d'utiliser le build précédement créé.
Les conteneurs sont mis en place et c'est le moment où l'on peut injecter des modifications dans le conteneur applicatif.

Les variables d'environnements sont accessibles. C'est le script **entrypoint.sh** ici qui se charge de toutes les actions.
## Installation
***
L'installation en local se lance par:
```
docker-compose up -d
```
ou en arm
```
docker-compose -f docker-compose-arm.yml up -d 
```

Dans la console artifakt on parle de jobs. Les plus utilisés sont:
* **Deploy**: Redéploie les conteneurs (en cas de changement sur les variables par exemple)
* **Build & deploy**: Reconstruction de l'image et redéploiement des conteneurs.

Ce package donne accès en local au site sur **https://localhost** et au backoffice sur **https://localhost/admin_base**
* Adresse e-mail : pub@prestashop.com _(à modifier)_
* Mot de passe : 0123456789 _(à modifier)_
 
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
* docker-compose-arm.yml
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
