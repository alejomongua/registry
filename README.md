# Project: Docker Registry with NGINX front (HTTPS)

## Layout:

    /my-registry/
    ├── docker-compose.yml
    ├── data/                  <-- Docker will create registry data here
    ├── nginx/
    │   └── registry.conf      <-- NGINX configuration
    └── certs/
        ├── fullchain.pem      <-- Your public SSL certificate (or CA bundle)
        └── privkey.pem        <-- Your private SSL key

## Quick start:

1. Place your certificates in `certs/` named `fullchain.pem` and `privkey.pem`.
2. Replace `tu-dominio.com` in `nginx/registry.conf` with your real domain.
3. Run:

```bash
# Edit .env to set your domain and ports
docker-compose up -d
```

## Generating REGISTRY_HTTP_SECRET

It's recommended to set a shared secret for `REGISTRY_HTTP_SECRET` when you have multiple registries behind a load-balancer.
You can generate it and add it to your `.env` with these idempotent commands:

```bash
# Generate a 32-byte hex secret
SECRET=$(openssl rand -hex 32)

# If .env doesn't exist, copy it from the example
[ -f .env ] || cp .env.example .env

# Insert or replace the REGISTRY_HTTP_SECRET variable in .env
if grep -q '^REGISTRY_HTTP_SECRET=' .env; then
    sed -i "s/^REGISTRY_HTTP_SECRET=.*/REGISTRY_HTTP_SECRET=${SECRET}/" .env
else
    echo "REGISTRY_HTTP_SECRET=${SECRET}" >> .env
fi

echo "REGISTRY_HTTP_SECRET set in .env"
```

You can also test first with `.env.example` by changing the target file in the script if you prefer.

## Usage:

```bash
source .env
# Tag
docker tag ruby:2.4.10 ${DOMAIN}:${NGINX_PORT}/ruby-legacy:2.4.10
# Login is not required because authentication is not implemented by default
# docker login ${DOMAIN}:${NGINX_PORT}
# Push
docker push ${DOMAIN}:${NGINX_PORT}/ruby-legacy:2.4.10
```

## Notes:
- The `registry` service listens over HTTP internally on port 5000. NGINX terminates TLS and acts as a reverse proxy.
- For production, use valid certificates (Let's Encrypt or another CA).
