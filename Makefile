#!/usr/bin/env make

.PHONY: run_website install_kind

run_website:
	docker build -t explorecalifornia.com . && \
		docker run -p 5000:80 -d --name explorecalifornia.com --rm explorecalifornia.com

stop_website:
	docker stop explorecalifornia.com

install_kind:
	curl -L --output ./kind https://github.com/kubernetes-sigs/kind/releases/download/v0.14.0/kind-linux-amd64 && \
		./kind --version

create_kind_cluster: install_kind create_docker_registry
	./kind create cluster --name explorecalifornia.com && \
		kubectl get nodes

create_docker_registry:
	if docker ps | grep -q 'local-registry'; \
		then echo "---> local-registry already created; skipping"; \
		else docker run --name local-registry -d --restart=always -p 5000:5000 registry:2; \
		fi
