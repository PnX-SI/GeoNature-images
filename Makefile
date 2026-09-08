-include make/*.mk

GEONATURE_IMAGE_PREFIX ?= geonature-

# base images parameters
TAG ?= $(shell git -C GeoNature describe --tags --always --dirty)
GEONATURE_BACKEND_IMAGE ?= $(GEONATURE_IMAGE_PREFIX)backend:$(TAG)
GEONATURE_BACKEND_DEV_IMAGE ?= $(GEONATURE_BACKEND_IMAGE)-dev
GEONATURE_FRONTEND_IMAGE ?= $(GEONATURE_IMAGE_PREFIX)frontend:$(TAG)
GEONATURE_FRONTEND_NGINX_IMAGE ?= $(GEONATURE_FRONTEND_IMAGE)-nginx
GEONATURE_FRONTEND_SOURCE_IMAGE ?= $(GEONATURE_FRONTEND_IMAGE)-source
GEONATURE_FRONTEND_DEV_IMAGE ?= $(GEONATURE_FRONTEND_IMAGE)-dev

# extra images parameters
EXTRA_TAG ?= $(shell git describe --tags --always --dirty)
GEONATURE_BACKEND_EXTRA_IMAGE ?= $(GEONATURE_IMAGE_PREFIX)backend-extra:$(EXTRA_TAG)
GEONATURE_BACKEND_EXTRA_DEV_IMAGE ?= $(GEONATURE_BACKEND_EXTRA_IMAGE)-dev
GEONATURE_FRONTEND_EXTRA_IMAGE ?= $(GEONATURE_IMAGE_PREFIX)frontend-extra:$(EXTRA_TAG)
GEONATURE_FRONTEND_EXTRA_SOURCE_IMAGE ?= $(GEONATURE_FRONTEND_EXTRA_IMAGE)-source
GEONATURE_FRONTEND_EXTRA_DEV_IMAGE ?= $(GEONATURE_FRONTEND_EXTRA_IMAGE)-dev

docker-list-images:
	@make --no-print-directory -C GeoNature docker-list-images \
		GEONATURE_BACKEND_IMAGE=${GEONATURE_BACKEND_IMAGE} \
		GEONATURE_BACKEND_DEV_IMAGE=${GEONATURE_BACKEND_DEV_IMAGE} \
		GEONATURE_FRONTEND_IMAGE=${GEONATURE_FRONTEND_IMAGE} \
		GEONATURE_FRONTEND_NGINX_IMAGE=${GEONATURE_FRONTEND_NGINX_IMAGE} \
		GEONATURE_FRONTEND_SOURCE_IMAGE=${GEONATURE_FRONTEND_SOURCE_IMAGE} \
		GEONATURE_FRONTEND_DEV_IMAGE=${GEONATURE_FRONTEND_DEV_IMAGE}
	@printf "%25s: %s\n" "backend-extra" "${GEONATURE_BACKEND_EXTRA_IMAGE}"
	@printf "%25s: %s\n" "backend-extra-dev" "${GEONATURE_BACKEND_EXTRA_DEV_IMAGE}"
	@printf "%25s: %s\n" "frontend-extra" "${GEONATURE_FRONTEND_EXTRA_IMAGE}"
	@printf "%25s: %s\n" "frontend-extra-source" "${GEONATURE_FRONTEND_EXTRA_SOURCE_IMAGE}"
	@printf "%25s: %s\n" "frontend-extra-dev" "${GEONATURE_FRONTEND_EXTRA_DEV_IMAGE}"

docker-backend:
	make -C GeoNature docker-backend GEONATURE_BACKEND_IMAGE=${GEONATURE_BACKEND_IMAGE}
	docker build \
		--build-arg GEONATURE_BACKEND_IMAGE=${GEONATURE_BACKEND_IMAGE} \
		-f ./Dockerfile-backend \
		--target=prod \
		-t ${GEONATURE_BACKEND_EXTRA_IMAGE} \
		.

docker-backend-dev:
	make -C GeoNature docker-backend-dev GEONATURE_BACKEND_DEV_IMAGE=${GEONATURE_BACKEND_DEV_IMAGE}
	docker build \
		--build-arg GEONATURE_BACKEND_DEV_IMAGE=${GEONATURE_BACKEND_DEV_IMAGE} \
		-f ./Dockerfile-backend \
		--target=dev \
		-t ${GEONATURE_BACKEND_EXTRA_DEV_IMAGE} \
		.

docker-frontend:
	make -C GeoNature docker-frontend-nginx GEONATURE_FRONTEND_NGINX_IMAGE=${GEONATURE_FRONTEND_NGINX_IMAGE}
	make -C GeoNature docker-frontend-source GEONATURE_FRONTEND_SOURCE_IMAGE=${GEONATURE_FRONTEND_SOURCE_IMAGE}
	docker build \
		--build-arg GEONATURE_FRONTEND_NGINX_IMAGE=${GEONATURE_FRONTEND_NGINX_IMAGE} \
		--build-arg GEONATURE_FRONTEND_SOURCE_IMAGE=${GEONATURE_FRONTEND_SOURCE_IMAGE} \
		-f ./Dockerfile-frontend \
		--target=prod \
		-t ${GEONATURE_FRONTEND_EXTRA_IMAGE} \
		.

docker-frontend-source:
	make -C GeoNature docker-frontend-source GEONATURE_FRONTEND_SOURCE_IMAGE=${GEONATURE_FRONTEND_SOURCE_IMAGE}
	docker build \
		--build-arg GEONATURE_FRONTEND_SOURCE_IMAGE=${GEONATURE_FRONTEND_SOURCE_IMAGE} \
		-f ./Dockerfile-frontend \
		--target=source \
		-t ${GEONATURE_FRONTEND_EXTRA_SOURCE_IMAGE} \
		.

docker-frontend-dev:
	make -C GeoNature docker-frontend-dev GEONATURE_FRONTEND_DEV_IMAGE=${GEONATURE_FRONTEND_DEV_IMAGE}
	docker build \
		--build-arg GEONATURE_FRONTEND_DEV_IMAGE=${GEONATURE_FRONTEND_DEV_IMAGE} \
		-f ./Dockerfile-frontend \
		--target=dev \
		-t ${GEONATURE_FRONTEND_EXTRA_DEV_IMAGE} \
		.

docker: docker-backend docker-frontend
docker-dev: docker-backend-dev docker-frontend-dev

-include Makefile.local
