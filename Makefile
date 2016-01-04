.PHONY:	build push

REPO = mesosphere
IMAGE = kubernetes-keygen
TAG = $(shell git describe --abbrev=0 --tags)

build:
	docker build -t $(REPO)/$(IMAGE):$(TAG) .

push: build
	docker push $(REPO)/$(IMAGE):$(TAG)

all: push
