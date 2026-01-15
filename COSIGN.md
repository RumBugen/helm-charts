# Cosign signature verification

This repository publishes Helm charts as OCI artifacts to:

- Docker Hub: `registry-1.docker.io/rumbugen/<chart>:<version>`
- GHCR: `ghcr.io/rumbugen/<chart>:<version>`

All OCI-published charts are signed with Cosign. Verify signatures before installing charts from OCI.

## Public key

The public key is stored in this repository as `cosign.pub`.

## Verify a chart

Example for Mailpiler `0.1.0`:

```bash
# GHCR
cosign verify --key cosign.pub ghcr.io/rumbugen/mailpiler:0.1.0

# Docker Hub
cosign verify --key cosign.pub registry-1.docker.io/rumbugen/mailpiler:0.1.0

# Install after verification
helm install mailpiler oci://ghcr.io/rumbugen/mailpiler --version 0.1.0
```
