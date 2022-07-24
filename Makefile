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

create_kind_cluster: install_kind
	./kind create cluster --name explorecalifornia.com --config ./kind_config.yaml || true && \
		kubectl get nodes

create_docker_registry:
	if docker ps | grep -q 'local-registry'; \
		then echo "---> local-registry already created; skipping"; \
		else docker run --name local-registry -d --restart=always -p 5000:5000 registry:2; \
		fi

connect_registry_to_kind_network:
	docker network connect kind local-registry || true

connect_registry_to_kind: connect_registry_to_kind_network
	kubectl apply -f ./kind_configmap.yaml

create_kind_cluster_with_registry: create_docker_registry
	$(MAKE) create_kind_cluster && $(MAKE) connect_registry_to_kind


delete_kind_cluster: delete_docker_registry
	./kind delete cluster --name explorecalifornia.com

delete_docker_registry:
	docker stop local-registry && docker rm local-registry
