# GeoNature-images

Ce dépôt fournit une image Docker de GeoNature étendu, contenant les modules externes supplémentaires suivants :

- [Monitoring](https://github.com/PnX-SI/gn_module_monitoring)
- [Dashboard](https://github.com/PnX-SI/gn_module_dashboard)
- [Export](https://github.com/PnX-SI/gn_module_export)

Les modules internes suivants, qui font déjà partie de l’image GeoNature de base, restent disponibles :

- Occtax
- Occhab
- Validation

Ce dépôt vous fournit aussi des outils facilitant le génération de vos propres images Docker avec les modules externes que vous souhaitez.

Les images de base de GeoNature sans module externe sont générées et disponibles directement dans le [dépôt de GeoNature](https://github.com/orgs/PnX-SI/packages?repo_name=GeoNature).  
Pour déployer GeoNature avec Docker, le dépôt [GeoNature-docker-services](https://github.com/PnX-SI/GeoNature-Docker-services) fournit un Docker-compose de base clé en main et des exemples pour des environnements plus spécifiques.

## Builder ses propres images

Avant tout, utilisez `make docker-list-images` pour visualiser les tags des images utilisées / produites.

### Configuration

Pour paramétrer les tags des images produites, créez un fichier `make/config.mk` à partir de `make/config.mk.sample`.

Il est conseillé de définir à minima `GEONATURE_IMAGE_PREFIX` pour utiliser un namespace spécifique à vos images.

Par défaut, les images extra sont buildées à partir des images de base fournies par le dépôt GeoNature. Vous pouvez paramétrer les images à utiliser en définissant `GEONATURE_UPSTREAM_IMAGE_PREFIX` et `UPSTREAM_TAG`.

### Build

Initialisez les sous-modules :

```
git submodule update --init ':(exclude)GeoNature'
```

Re-vérifier les tags de vos images avec `make docker-list-images`.

- Pour générer les images de production : `make docker`
- Pour générer les images de dev : `make docker-dev`

Si vous souhaitez également rebuilder les images de base, initialisez également le sous-module GeoNature :

```
git submodule update --init --depth 1 GeoNature
git -C GeoNature submodule update --init --depth 1
git -C GeoNature config remote.origin.fetch '+refs/heads/develop:refs/remotes/origin/develop'  # pour éviter les soucis avec --depth=1
```

Pour personnaliser le tag de vos images, utilisez les paramètres `GEONATURE_IMAGE_PREFIX`, `BASE_TAG` et `EXTRA_TAG` (voir `make/config.mk.sample`).

Pour mettre à jour l’ensemble des sous-modules sur leur dernier commit de la branche `develop`, vous pouvez exécuter :

```
git submodule update --remote
git -C GeoNature submodule update  # si GeoNature est initialisé
```

## Installation d'un module externe

Cette section décrit la procédure d'ajout d'un module externe sur une instance GeoNature dockerisée. Cette procédure nécessite de créer une image Docker dédiée.

### Étape 1 : Ajouter le code source du module

Pour commencer, intégrer le code source du module sous forme de sous-module git :

  ```shell
  git submodule add <repo_module>
  ```

### Étape 2 : Ajouter le module dans l'image Docker

Une fois que le code source du module est présent, vous devez l'ajouter à la construction des images Docker pour le backend et le frontend de GeoNature (`geonature-backend-extra` et `geonature-frontend-extra`).

1. Ouvrez le fichier `Dockerfile-backend` et ajoutez les lignes suivantes **avant** la ligne `FROM ${GEONATURE_BACKEND_IMAGE} AS base_env` :

   ```docker
   FROM build AS build-nom-module
   WORKDIR /build/
   COPY ./nom_module .
   RUN python setup.py bdist_wheel
   ```

1. Toujours dans le même fichier, ajoutez la ligne suivante **après** `COPY --from=build-monitoring /build/dist/*.whl .` :

   ```docker
   COPY --from=build-nom-module /build/dist/*.whl .
   ```

1. Pour pouvoir développer sur votre module avec Docker, dans le stage `dev`, faites évoluer la commande d’installation des modules en mode éditable :

  ```docker
  RUN --mount=type=cache,target=/root/.cache \
      --mount=type=bind,source=.,target=/sources,rw \
      uv pip install --system \
      -e /sources/gn_module_export \
      -e /sources/gn_module_dashboard \
      -e /sources/gn_module_monitoring \
      -e /sources/mon_module
  ```

1. Si votre module possède un frontend, ouvrez le fichier `Dockerfile-frontend` et ajouter les lignes suivantes **avant** `FROM source AS build` (dans le stage `source` donc):

  ```docker
  WORKDIR /build/external_modules/module_code
  COPY ./mon_module/frontend/ .
  ```

1. Si votre frontend a des dépendances à installer, toujours dans `Dockerfile-frontend` :

Rajouter le bloc suivant **avant** `FROM ${GEONATURE_FRONTEND_SOURCE_IMAGE} AS source` :

  ```docker
  FROM ${NODE_IMAGE} AS mon_module-node-modules

  WORKDIR /dist/mon_module

  COPY ./mon_module/frontend/package.json .
  COPY ./mon_module/frontend/package-lock.json .

  RUN --mount=type=cache,target=/root/.npm \
    npm ci --omit=peer

  ```

Puis rajouter après la ligne `COPY ./mon_module/frontend/ .` que vous avec ajoutez à l’étape précédente dans le stage `source` la ligne suivante :

  ```docker
  COPY --from=mon_module-node-modules /dist/mon_module/node_modules node_modules
  ```

1. Pour pouvoir développer sur votre module avec Docker, dans le stage `dev`, rajouter la ligne suivante :

  ```docker
  COPY --from=monitorings-node-modules /dist/gn_module_monitoring /dist/gn_module_monitoring
  ```

Puis mettez à jour la liste des liens symboliques dans `external_modules` :

  ```docker
  RUN ln -s /dist/gn_module_export external_modules/exports \
    && ln -s /dist/gn_module_dashboard external_modules/dashboard \
    && ln -s /dist/gn_module_monitoring external_modules/monitorings \
    && ln -s /dist/mon_module external_modules/module_code
  ```
