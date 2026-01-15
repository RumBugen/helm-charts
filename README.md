# Helm Charts

This repository publishes Helm charts via:

- **GitHub Pages**
- **OCI registries** (Docker Hub + GHCR)

## Usage

### OCI (Docker Hub / GHCR)

```bash
# GHCR
helm install mailpiler oci://ghcr.io/rumbugen/mailpiler --version 0.1.0

# Docker Hub
helm install mailpiler oci://registry-1.docker.io/rumbugen/mailpiler --version 0.1.0
```

### GitHub Pages repo

```bash
helm repo add charts https://rumbugen.github.io/helm-charts/
helm repo update
helm search repo charts
helm install mailpiler charts/mailpiler --set mailpiler.hostname=archive.example.com
```

## Charts

- `charts/mailpiler`: Mailpiler with official Manticore chart; MariaDB and Memcached as CloudPirates dependencies.

## Signed commits

All commits in this repository should be GPG- or SSH-signed. Enable commit signing locally before pushing.

Enforcement is typically done via GitHub branch protection (“Require signed commits”) and the `Check signed commits` GitHub Action.

## Chart signatures (Cosign)

OCI-published charts are signed with Cosign. See `COSIGN.md` for verification instructions.

## License
Licensed under the Apache License, Version 2.0. See the LICENSE file.