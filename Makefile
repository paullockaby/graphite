# stop on error, no built in rules, run silently
MAKEFLAGS="-S -s -r"

# get tag information
IMAGE_COMMIT := $(shell git log -1 | head -n 1 | cut -d" " -f2)
IMAGE_TAG := $(shell git tag --contains ${IMAGE_COMMIT})

# get image id based on tag or commit
IMAGE_VERSION := $(or $(IMAGE_TAG),$(IMAGE_COMMIT))
IMAGE_NAME := "ghcr.io/paullockaby/graphite"
IMAGE_ID := "${IMAGE_NAME}:${IMAGE_VERSION}"

all: build

.PHONY: build
build:
	@echo "building image for ${IMAGE_ID}"
	docker build -t $(IMAGE_NAME):latest -t $(IMAGE_ID) .

.PHONY: buildx
buildx:
	@echo "building multiarch image for ${IMAGE_ID}"
	docker buildx build --platform linux/amd64,linux/arm64 -t $(IMAGE_ID) .

.PHONY: push
push:
	@echo "pushing $(IMAGE_ID)"
	docker buildx build --push --platform linux/amd64,linux/arm64 -t $(IMAGE_ID) .

.PHONY: clean
clean:
	@echo "removing built image ${IMAGE_ID}"
	docker image rm $(IMAGE_NAME):latest $(IMAGE_ID)
