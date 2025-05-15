#!/bin/bash

if [[ -z $ANSIBLE_GALAXY_SERVER_CERTIFIED_TOKEN || -z $ANSIBLE_GALAXY_SERVER_VALIDATED_TOKEN ]]
then
    echo "A valid Automation Hub token is required, Set the following environment variables before continuing"
    echo "export ANSIBLE_GALAXY_SERVER_CERTIFIED_TOKEN=<token>"
    echo "export ANSIBLE_GALAXY_SERVER_VALIDATED_TOKEN=<token>"
    exit 1
fi

# log in to pull the base EE image
if ! podman login --get-login registry.redhat.io > /dev/null
then
    echo "Run 'podman login registry.redhat.io' before continuing"
    exit 1
fi

# create EE definition
rm -rf ./context/*
ansible-builder create \
    --file execution-environment.yml \
    --context ./context \
    -v 3 | tee ansible-builder.log

# remove existing manifest
_tag=$(date +%Y%m%d)
podman manifest rm quay.io/jce-redhat/multi-arch-ee:${_tag}

# create manifest for EE image
podman manifest create quay.io/jce-redhat/multi-arch-ee:${_tag}

# build EE for multiple architectures from the EE context
pushd ./context/ > /dev/null
podman build --platform linux/amd64,linux/arm64 \
  --build-arg ANSIBLE_GALAXY_SERVER_CERTIFIED_TOKEN \
  --build-arg ANSIBLE_GALAXY_SERVER_VALIDATED_TOKEN \
  --manifest quay.io/jce-redhat/multi-arch-ee:${_tag} . \
  | tee podman-build.log
popd > /dev/null

# inspect manifest content
#podman manifest inspect quay.io/jce-redhat/multi-arch-ee:${_tag}

# tag manifest as latest
#podman tag quay.io/jce-redhat/multi-arch-ee:${_tag} quay.io/jce-redhat/multi-arch-ee:latest

# push all manifest content to repository
# using --all is important here, it pushes all content and not
# just the native platform content
#podman manifest push --all quay.io/jce-redhat/multi-arch-ee:${_tag}
#podman manifest push --all quay.io/jce-redhat/multi-arch-ee:latest
