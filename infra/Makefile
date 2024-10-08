.DEFAULT_GOAL := help
SHELL := /usr/bin/env bash
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-builtin-variables

.PHONY: bootstrap e2e format flux-ui \
		help hosts init validate wait-apps

bootstrap: init ## create a local dev cluster with kind and bootstrap with flux via gitops
	./scripts/create-cluster.sh kind dev
	./scripts/provision-cluster.sh dev kind-dev --gitops
	@$(MAKE) wait-apps

clean: ## remove any locally created test resources
	kind delete cluster --name dev

e2e: init ## create a local dev cluster with kind, sync with flux without gitops and clean it up after the checks pass
	./scripts/create-cluster.sh kind dev
	./scripts/provision-cluster.sh dev kind-dev
	@$(MAKE) wait-apps
	kind delete cluster --name dev

format: init ## format yaml and json files
	prettier --write "**/*.{json,yaml,yml}" --log-level error

flux-ui: init ## port-forward to the current kubernetes cluster so flux UI can be accessed in http://localhost:9001
	kubectl -n flux-system port-forward svc/weave-gitops 9001:9001

help: ## list available commands
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

hosts: ## Define local hostnames that will point to the cluster IP in relation to the ingresses
	./scripts/set-hosts.sh

init: ## verify that all the required commands are already installed
	@if [ -z "$$CI" ]; then \
		function cmd { \
			if ! command -v "$$1" &>/dev/null ; then \
				echo "error: missing required command in PATH: $$1" >&2 ;\
				return 1 ;\
			fi \
		} ;\
		cmd age-keygen ;\
		cmd flux ;\
		cmd kind ;\
		cmd kubeconform ;\
		cmd kubectl ;\
		cmd prettier ;\
		cmd sops ;\
		cmd yq ;\
		cp .githooks/* .git/hooks/ ;\
		git config diff.sopsdiffer.textconv "sops -d" ;\
	fi

validate: init # validate the flux custom resources and kustomize overlays using kubeconform
	./scripts/validate.sh

wait-apps: init # wait for resources provisioned in the current context app cluster
	kubectl -n flux-system wait kustomization/infra-controllers --for=condition=ready --timeout=5m
	kubectl -n flux-system wait kustomization/infra-configs --for=condition=ready --timeout=5m
	kubectl -n flux-system wait kustomization/apps --for=condition=ready --timeout=5m
	kubectl -n podinfo wait helmrelease/podinfo --for=condition=ready --timeout=5m


create-stage: init ## create a local staging cluster with kind and bootstrap with flux via gitops
	./scripts/create-cluster.sh kind stage
	./scripts/provision-cluster.sh stage kind-stage --gitops
	@$(MAKE) wait-apps

create-prod: init ## create a local prod cluster with kind and bootstrap with flux via gitops
	./scripts/create-cluster.sh kind prod
	./scripts/provision-cluster.sh prod kind-prod --gitops
	@$(MAKE) wait-apps