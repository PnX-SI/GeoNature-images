# GeoNature-images

Ce dépôt fournit une image Docker de GeoNature contenant les modules supplémentaires suivants :

- [Monitoring](https://github.com/PnX-SI/gn_module_monitoring)
- [Dashboard](https://github.com/PnX-SI/gn_module_dashboard)
- [Export](https://github.com/PnX-SI/gn_module_export)

Les modules suivants, qui font déjà partie de l’image GeoNature de base, restent disponibles :

- Occtax
- Occhab
- Validation

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
