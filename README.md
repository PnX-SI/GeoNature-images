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

Si vous souhaitez également rebuilder les images de base, initialisez le sous-module GeoNature :

```
git submodule init
git submodule update
```

Vous pouvez alors faire pointer le sous-module GeoNature sur le commit de votre choix.

Pour personnaliser le tags de vos images, utilisez les paramètres `GEONATURE_IMAGE_PREFIX`, `TAG` et `EXTRA_TAG`.

### Build

Re-vérifier les tags de vos images avec `make docker-list-images`.

- Pour générer les images de production : `make docker`
- Pour générer les images de dev : `make docker-dev`