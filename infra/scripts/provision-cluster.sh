#!/usr/bin/env bash

# Exit if one of the scripts fail
set -e

# Get the directory of the current script
script_dir="$(dirname "${BASH_SOURCE[0]}")"

# shellcheck disable=SC1091
source "${script_dir}"/utils.sh

# Initialize flags
gitops_flag=false

# Parse flags
while (( "$#" )); do
  case "$1" in
    --gitops)
      gitops_flag=true
      shift
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done

# Set positional arguments in their proper place
eval set -- "$PARAMS"

# Check that cluster_name is provided
if [ -z "$1" ]
then
	print_red "Error: No kubernetes cluster name provided."
	echo "Usage: $0 [--gitops] <cluster_name> <context-name>"
	exit 1
fi

# Check that context_name is provided
if [ -z "$2" ]
then
	print_red "Error: No kubernetes context name provided."
	echo "Usage: $0 [--gitops] <cluster_name> <context-name>"
	exit 1
fi

cluster_name="$1"
context_name="$2"
private_key_path="./infra/clusters/${cluster_name}/sops.agekey"

# Source the .envrc file to load the GITHUB_USER and GITHUB_REPO environment variables
# shellcheck source=/dev/null
source .envrc

if [ "$gitops_flag" = true ] ; then
	# Provision flux the "gitops" way (https://fluxcd.io/flux/cmd/flux_bootstrap/)
	echo ""
	print_blue "Provisioning flux with gitops..."
	flux bootstrap github \
	--branch=main \
	--components-extra=image-reflector-controller,image-automation-controller \
	--context="${context_name}" \
	--owner="${GITHUB_OWNER}" \
	--path=infra/clusters/"${cluster_name}" \
	--personal \
	--read-write-key \
	--repository="${GITHUB_REPO}"
else
	echo ""
	print_blue "Provisioning flux without gitops..."
	flux install \
	--components-extra=image-reflector-controller,image-automation-controller \
	--context="${context_name}"
	flux create source git flux-system \
	--context="${context_name}" \
	--url=https://github.com/"${GITHUB_OWNER}"/"${GITHUB_REPO}" \
	--branch=main \
	--ignore-paths=infra/clusters/"${cluster_name}"/flux-system/
	flux create kustomization flux-system \
	--context="${context_name}" \
	--source=flux-system \
	--path=./infra/clusters/"${cluster_name}"
fi
print_green "Cluster provisioned successfully"


# Provision the secret that will be used to access the private registry
echo ""
print_blue "🔑 Creating secret acr-credentials to access ACR..."

if kubectl get secret acr-credentials --context="${context_name}" --namespace=default > /dev/null 2>&1; then
	print_yellow "Secret 'acr-credentials' already exists. Skipping creation."
else
kubectl create secret docker-registry acr-credentials \
    --docker-server=${ACR_NAME} \
    --docker-username=${ACR_USERNAME} \
    --docker-password=${ACR_TOKEN} \
	--namespace=default

	print_green "Secret 'acr-credentials' created."
fi
echo ""


# Provision the secret that will be used to access the private registry
echo ""
print_blue "🔑 Creating secret github-credentials to access GitHub..."

flux create secret git github-credentials \
	--url https://github.com/${GITHUB_OWNER}/${GITHUB_REPO} \
	--username ${GITHUB_OWNER} \
	--password ${GITHUB_TOKEN} \
	--namespace default

print_green "Secret 'github-credentials' created."

echo ""

