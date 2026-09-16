-include make/*.mk

# Should we build GeoNature base images? Default to true if submodule initialized.
GEONATURE_BUILD_BASE ?= $(if $(wildcard GeoNature/.git),1,0)

GEONATURE_UPSTREAM_IMAGE_PREFIX ?= ghcr.io/pnx-si/geonature-
UPSTREAM_TAG ?= latest

GEONATURE_IMAGE_PREFIX ?= geonature-

ifeq ($(GEONATURE_BUILD_BASE),1)
GEONATURE_BASE_IMAGE_PREFIX ?= ${GEONATURE_IMAGE_PREFIX}
TAG ?= $(shell git -C GeoNature describe --tags --always --dirty)
BASE_TAG ?= ${TAG}
else
GEONATURE_BASE_IMAGE_PREFIX ?= ${GEONATURE_UPSTREAM_IMAGE_PREFIX}
BASE_TAG ?= ${UPSTREAM_TAG}
endif

GEONATURE_EXTRA_IMAGE_PREFIX ?= ${GEONATURE_IMAGE_PREFIX}
EXTRA_TAG ?= $(shell git describe --tags --always --dirty)

# base images parameters
GEONATURE_BACKEND_IMAGE ?= $(GEONATURE_BASE_IMAGE_PREFIX)backend:$(BASE_TAG)
GEONATURE_BACKEND_DEV_IMAGE ?= $(GEONATURE_BACKEND_IMAGE)-dev
GEONATURE_FRONTEND_IMAGE ?= $(GEONATURE_BASE_IMAGE_PREFIX)frontend:$(BASE_TAG)
GEONATURE_FRONTEND_NGINX_IMAGE ?= $(GEONATURE_FRONTEND_IMAGE)-nginx
GEONATURE_FRONTEND_SOURCE_IMAGE ?= $(GEONATURE_FRONTEND_IMAGE)-source
GEONATURE_FRONTEND_DEV_IMAGE ?= $(GEONATURE_FRONTEND_IMAGE)-dev

# extra images parameters
GEONATURE_BACKEND_EXTRA_IMAGE ?= $(GEONATURE_EXTRA_IMAGE_PREFIX)backend-extra:$(EXTRA_TAG)
GEONATURE_BACKEND_EXTRA_DEV_IMAGE ?= $(GEONATURE_BACKEND_EXTRA_IMAGE)-dev
GEONATURE_FRONTEND_EXTRA_IMAGE ?= $(GEONATURE_EXTRA_IMAGE_PREFIX)frontend-extra:$(EXTRA_TAG)
GEONATURE_FRONTEND_EXTRA_SOURCE_IMAGE ?= $(GEONATURE_FRONTEND_EXTRA_IMAGE)-source
GEONATURE_FRONTEND_EXTRA_DEV_IMAGE ?= $(GEONATURE_FRONTEND_EXTRA_IMAGE)-dev

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

docker: docker-backend docker-frontend
docker-dev: docker-backend-dev docker-frontend-dev

-include Makefile.local
