# Mailpiler

This chart deploys Mailpiler for Kubernetes. MariaDB and Memcached are installed by default as dependencies from the CloudPirates Helm repo. Manticore is deployed via the official `manticoresearch` Helm chart.

## Install

### OCI (GHCR / Docker Hub)

Verify the signature first (recommended): see `COSIGN.md`.

```bash
# GHCR
helm install mailpiler oci://ghcr.io/rumbugen/mailpiler --version 0.1.0 \
  --set mailpiler.hostname=archive.example.com

# Docker Hub
helm install mailpiler oci://registry-1.docker.io/rumbugen/mailpiler --version 0.1.0 \
  --set mailpiler.hostname=archive.example.com
```

### GitHub Pages repo

```bash
helm repo add charts https://rumbugen.github.io/helm-charts/
helm repo update
helm install mailpiler charts/mailpiler \
  --set mailpiler.hostname=archive.example.com
```

## Components

- **Mailpiler**: SMTP + Web UI (ports 25/80/443)
- **MariaDB**: via CloudPirates dependency (`mariadb.enabled=true`)
- **Manticore**: via `manticoresearch` dependency (full-text index)
- **Memcached**: via CloudPirates dependency (`memcached.enabled=true`)

## Key values

- `mailpiler.hostname`: public hostname for Mailpiler
- `mailpiler.rtIndex`: enable RT index (1/0)
- `mailpiler.pathPrefix`: optional URL prefix (trailing `/` is optional)
- `persistence.config` / `persistence.store`: PVCs for `/etc/piler` and `/var/piler/store`
- `service.type`: `ClusterIP` (default) or `LoadBalancer`
- `service.ports.smtp/http/https`: service ports (you can expose SMTP on a non-25 port)
- `manticoresearch.worker.replicaCount`: number of Manticore worker pods (default: 1)
- `manticoresearch.balancer.enabled`: enable the Manticore balancer (default: true)
- `manticoreInit.enabled`: create required Mailpiler RT tables (`piler1`, `tag1`, `note1`, `audit1`) after install/upgrade
- `memcached.config.memoryLimit`: cache size in MB (dependency)
- `mariadb.auth.database` / `mariadb.auth.username`: database + user for Mailpiler
- `mariadb.auth.password`: optional, otherwise a random password is generated in the Secret

## Default credentials

Mailpiler ships with a built-in admin account. It is strongly recommended to change this password on first install.

- Username: `admin@local`
- Password: `pilerrocks`

To set a new password, provide `mailpiler.adminUserPasswordHash` (a `crypt()` hash). The built-in default uses **MD5-crypt** (hash prefix `$1$`), but it is recommended to use a stronger scheme like **SHA512-crypt** (hash prefix `$6$`):

```bash
openssl passwd -6 'YourNewPassword'
```

## Manticore connection

The Mailpiler container expects Manticore on:

- `SPHINX_HOSTNAME`: `<host>:9306`
- `SPHINX_HOSTNAME_READONLY`: `<host>:9307`

The chart creates a small Service (`<release>-manticore`, for example `mailpiler-manticore`) that exposes **both** ports and routes them to the **Manticore workers**.

This is important: Mailpiler performs `REPLACE INTO ...` statements for RT indexing, and the `manticoresearch` chart's **balancer** exposes *distributed* tables which are not writable by default. Connecting Mailpiler to the workers avoids errors like `table 'piler1' does not support INSERT`.

## Exposing SMTP on a different port

Mailpiler listens on port **25** inside the pod, but you can expose it on a different Kubernetes Service port (useful when sending from an external mail system like Mailcow):

```bash
helm upgrade --install mailpiler charts/mailpiler \
  --set service.type=LoadBalancer \
  --set service.ports.smtp=2525
```

## Expose only SMTP via LoadBalancer (MetalLB)

If you want the web UI to stay on `Ingress` (Traefik/nginx/etc.) but expose **only SMTP** externally, enable the dedicated SMTP Service:

```bash
helm upgrade --install mailpiler charts/mailpiler \
  --set service.type=ClusterIP \
  --set service.expose.smtp=false \
  --set smtpService.enabled=true \
  --set smtpService.type=LoadBalancer \
  --set smtpService.port=25
```

## Exposure options

- **Web UI**: prefer `ingress.enabled=true` (Ingress controller required) or `httpRoute.enabled=true` (Gateway API required).
- **SMTP ingest**: prefer `service.type=LoadBalancer` so it is reachable outside the cluster (MetalLB / cloud LB).
  - You can expose SMTP on a non-25 port using `service.ports.smtp` (Mailpiler still listens on 25 inside the pod).

## External MariaDB

```bash
helm install mailpiler charts/mailpiler \
  --set mariadb.enabled=false \
  --set database.host=my-db.example.com \
  --set database.name=piler \
  --set database.user=piler \
  --set database.password=...
```

Alternatively, set `database.existingSecret` (key via `database.passwordKey`).

## External Memcached

```bash
helm install mailpiler charts/mailpiler \
  --set memcached.enabled=false \
  --set memcached.host=my-memcached.example.com
```

## MariaDB dependency Secrets

If you set `mariadb.auth.existingSecret`, the Secret must contain the key defined in `mariadb.auth.secretKeys.userPasswordKey`. Mailpiler reads that Secret directly.

## Helm tests

`helm test` validates:

- Ports (Mailpiler, MariaDB/Memcached/Manticore as enabled)
- Manticore tables exist (`piler1`, `tag1`, `note1`, `audit1`)