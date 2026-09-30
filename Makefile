-include make/*.mk

# Should we build GeoNature base images? Default to true if the submodule is initialized.
GEONATURE_BUILD_BASE ?= $(if $(wildcard GeoNature/.git),1,0)

# upstream parameters are used if GEONATURE_BUILD_BASE=0
GEONATURE_UPSTREAM_IMAGE_PREFIX ?= ghcr.io/pnx-si/geonature-
UPSTREAM_TAG ?= latest

# default image prefix
GEONATURE_IMAGE_PREFIX ?= geonature-
GEONATURE_PROD_IMAGE_PREFIX ?= $(GEONATURE_IMAGE_PREFIX)
GEONATURE_DEV_IMAGE_PREFIX ?= $(GEONATURE_IMAGE_PREFIX)

ifeq ($(GEONATURE_BUILD_BASE),1)
BASE_TAG ?= $(shell git -C GeoNature describe --tags --always --dirty)
else
GEONATURE_BASE_IMAGE_PREFIX ?= ${GEONATURE_UPSTREAM_IMAGE_PREFIX}
BASE_TAG := $(UPSTREAM_TAG)
endif

# GEONATURE_BASE_IMAGE_PREFIX have precedence over GEONATURE_{PROD,DEV}_IMAGE_PREFIX to define GEONATURE_BASE_{PROD,DEV}_IMAGE_PREFIX
ifeq ($(GEONATURE_BASE_IMAGE_PREFIX),)
GEONATURE_BASE_PROD_IMAGE_PREFIX ?= $(GEONATURE_PROD_IMAGE_PREFIX)
GEONATURE_BASE_DEV_IMAGE_PREFIX ?= $(GEONATURE_DEV_IMAGE_PREFIX)
else
GEONATURE_BASE_PROD_IMAGE_PREFIX ?= $(GEONATURE_BASE_IMAGE_PREFIX)
GEONATURE_BASE_DEV_IMAGE_PREFIX ?= $(GEONATURE_BASE_IMAGE_PREFIX)
endif

# GEONATURE_EXTRA_IMAGE_PREFIX have precedence over GEONATURE_{PROD,DEV}_IMAGE_PREFIX to define GEONATURE_EXTRA_{PROD,DEV}_IMAGE_PREFIX
ifeq ($(GEONATURE_EXTRA_IMAGE_PREFIX),)
GEONATURE_EXTRA_PROD_IMAGE_PREFIX ?= $(GEONATURE_PROD_IMAGE_PREFIX)
GEONATURE_EXTRA_DEV_IMAGE_PREFIX ?= $(GEONATURE_DEV_IMAGE_PREFIX)
else
GEONATURE_EXTRA_PROD_IMAGE_PREFIX ?= $(GEONATURE_EXTRA_IMAGE_PREFIX)
GEONATURE_EXTRA_DEV_IMAGE_PREFIX ?= $(GEONATURE_EXTRA_IMAGE_PREFIX)
endif

EXTRA_TAG ?= $(shell git describe --tags --always --dirty)

DEV_TAG ?= dev
# dev tags
ifeq ($(DEV_TAG),)
BASE_DEV_TAG ?= $(BASE_TAG)-dev
EXTRA_DEV_TAG ?= $(EXTRA_TAG)-dev
else
BASE_DEV_TAG ?= $(DEV_TAG)
EXTRA_DEV_TAG ?= $(DEV_TAG)
endif

### base images
# prod
GEONATURE_BACKEND_IMAGE ?= $(GEONATURE_BASE_PROD_IMAGE_PREFIX)backend:$(BASE_TAG)
GEONATURE_FRONTEND_IMAGE ?= $(GEONATURE_BASE_PROD_IMAGE_PREFIX)frontend:$(BASE_TAG)
GEONATURE_FRONTEND_NGINX_IMAGE ?= $(GEONATURE_BASE_PROD_IMAGE_PREFIX)frontend:$(BASE_TAG)-nginx
GEONATURE_FRONTEND_SOURCE_IMAGE ?= $(GEONATURE_BASE_PROD_IMAGE_PREFIX)frontend:$(BASE_TAG)-source
# dev
GEONATURE_BACKEND_DEV_IMAGE ?= $(GEONATURE_BASE_DEV_IMAGE_PREFIX)backend:$(BASE_DEV_TAG)
GEONATURE_FRONTEND_DEV_IMAGE ?= $(GEONATURE_BASE_DEV_IMAGE_PREFIX)frontend:$(BASE_DEV_TAG)

### extra images
# prod
GEONATURE_BACKEND_EXTRA_IMAGE ?= $(GEONATURE_EXTRA_PROD_IMAGE_PREFIX)backend-extra:$(EXTRA_TAG)
GEONATURE_FRONTEND_EXTRA_IMAGE ?= $(GEONATURE_EXTRA_PROD_IMAGE_PREFIX)frontend-extra:$(EXTRA_TAG)
GEONATURE_FRONTEND_EXTRA_SOURCE_IMAGE ?= $(GEONATURE_EXTRA_PROD_IMAGE_PREFIX)frontend-extra:$(EXTRA_TAG)-source
# dev
GEONATURE_BACKEND_EXTRA_DEV_IMAGE ?= $(GEONATURE_EXTRA_DEV_IMAGE_PREFIX)backend-extra:$(EXTRA_DEV_TAG)
GEONATURE_FRONTEND_EXTRA_DEV_IMAGE ?= $(GEONATURE_EXTRA_DEV_IMAGE_PREFIX)frontend-extra:$(EXTRA_DEV_TAG)

docker-list-images:
	@echo "Base images:"
	@printf "%25s: %s\n" "backend" "${GEONATURE_BACKEND_IMAGE}"
	@printf "%25s: %s\n" "backend-dev" "${GEONATURE_BACKEND_DEV_IMAGE}"
	@printf "%25s: %s\n" "frontend" "${GEONATURE_FRONTEND_IMAGE}"
	@printf "%25s: %s\n" "frontend-nginx" "${GEONATURE_FRONTEND_NGINX_IMAGE}"
	@printf "%25s: %s\n" "frontend-source" "${GEONATURE_FRONTEND_SOURCE_IMAGE}"
	@printf "%25s: %s\n" "frontend-dev" "${GEONATURE_FRONTEND_DEV_IMAGE}"
	@echo "Extra images:"
	@printf "%25s: %s\n" "backend-extra" "${GEONATURE_BACKEND_EXTRA_IMAGE}"
	@printf "%25s: %s\n" "backend-extra-dev" "${GEONATURE_BACKEND_EXTRA_DEV_IMAGE}"
	@printf "%25s: %s\n" "frontend-extra" "${GEONATURE_FRONTEND_EXTRA_IMAGE}"
	@printf "%25s: %s\n" "frontend-extra-source" "${GEONATURE_FRONTEND_EXTRA_SOURCE_IMAGE}"
	@printf "%25s: %s\n" "frontend-extra-dev" "${GEONATURE_FRONTEND_EXTRA_DEV_IMAGE}"

docker-backend:
ifeq ($(GEONATURE_BUILD_BASE),1)
	make -C GeoNature docker-backend GEONATURE_BACKEND_IMAGE=${GEONATURE_BACKEND_IMAGE}
endif
	docker build \
		--build-arg GEONATURE_BACKEND_IMAGE=${GEONATURE_BACKEND_IMAGE} \
		-f ./Dockerfile-backend \
		--target=prod \
		-t ${GEONATURE_BACKEND_EXTRA_IMAGE} \
		.

docker-backend-dev:
ifeq ($(GEONATURE_BUILD_BASE),1)
	make -C GeoNature docker-backend-dev GEONATURE_BACKEND_DEV_IMAGE=${GEONATURE_BACKEND_DEV_IMAGE}
endif
	docker build \
		--build-arg GEONATURE_BACKEND_DEV_IMAGE=${GEONATURE_BACKEND_DEV_IMAGE} \
		-f ./Dockerfile-backend \
		--target=dev \
		-t ${GEONATURE_BACKEND_EXTRA_DEV_IMAGE} \
		.

docker-frontend:
ifeq ($(GEONATURE_BUILD_BASE),1)
	make -C GeoNature docker-frontend-nginx GEONATURE_FRONTEND_NGINX_IMAGE=${GEONATURE_FRONTEND_NGINX_IMAGE}
	make -C GeoNature docker-frontend-source GEONATURE_FRONTEND_SOURCE_IMAGE=${GEONATURE_FRONTEND_SOURCE_IMAGE}
endif
	docker build \
		--build-arg GEONATURE_FRONTEND_NGINX_IMAGE=${GEONATURE_FRONTEND_NGINX_IMAGE} \
		--build-arg GEONATURE_FRONTEND_SOURCE_IMAGE=${GEONATURE_FRONTEND_SOURCE_IMAGE} \
		-f ./Dockerfile-frontend \
		--target=prod \
		-t ${GEONATURE_FRONTEND_EXTRA_IMAGE} \
		.

docker-frontend-source:
ifeq ($(GEONATURE_BUILD_BASE),1)
	make -C GeoNature docker-frontend-source GEONATURE_FRONTEND_SOURCE_IMAGE=${GEONATURE_FRONTEND_SOURCE_IMAGE}
endif
	docker build \
		--build-arg GEONATURE_FRONTEND_SOURCE_IMAGE=${GEONATURE_FRONTEND_SOURCE_IMAGE} \
		-f ./Dockerfile-frontend \
		--target=source \
		-t ${GEONATURE_FRONTEND_EXTRA_SOURCE_IMAGE} \
		.

docker-frontend-dev:
ifeq ($(GEONATURE_BUILD_BASE),1)
	make -C GeoNature docker-frontend-dev GEONATURE_FRONTEND_DEV_IMAGE=${GEONATURE_FRONTEND_DEV_IMAGE}
endif
	docker build \
		--build-arg GEONATURE_FRONTEND_DEV_IMAGE=${GEONATURE_FRONTEND_DEV_IMAGE} \
		-f ./Dockerfile-frontend \
		--target=dev \
		-t ${GEONATURE_FRONTEND_EXTRA_DEV_IMAGE} \
		.

docker-push-backend:
	docker push ${GEONATURE_BACKEND_EXTRA_IMAGE}

docker-push-frontend:
	docker push ${GEONATURE_FRONTEND_EXTRA_IMAGE}

docker: docker-backend docker-frontend
docker-dev: docker-backend-dev docker-frontend-dev
docker-push: docker-push-backend docker-push-frontend

-include Makefile.local
