.PHONY:	build push

REPO = mesosphere
IMAGE = kubernetes-keygen
TAG = v1.0.0

build:
	docker build -t $(REPO)/$(IMAGE):$(TAG) .

push: build
	docker push $(REPO)/$(IMAGE):$(TAG)

all: push
