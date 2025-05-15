# Example multi-arch Execution Environment image for AAP

An example of how to build a multi-arch EE image, based on information from [How to build multi-architecture container images](https://developers.redhat.com/articles/2023/11/03/how-build-multi-architecture-container-images).  The [ansible-builder](https://ansible.readthedocs.io/) tool does not support this capability, so the `build.sh` in the repository takes a multi-step approach:

1. Create the EE context using the `ansible-builder create` command
2. Create a container image manifest for the EE using the `podman manifest` command, then build the EEs using podman.

When building the EE image for a non-native architecture, podman uses the QEMU emulator by default, and the required packages are [not available on Red Hat Enterprise Linux](https://access.redhat.com/solutions/5654221).  The multi-arch build will work on a Fedora system, as well as [Podman Desktop](https://podman-desktop.io/) on MacOS.

The demo EE definition will pull in certified collections from Red Hat Automation Hub, so an Automation Hub token is required when creating the EE.
