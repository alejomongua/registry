# Proyecto: Docker Registry con NGINX en front (HTTPS)

Estructura recomendada:

/mi-registro/
├── docker-compose.yml
├── data/                  <-- Docker creará los datos del registro aquí
├── nginx/
│   └── registry.conf      <-- La configuración para NGINX
└── certs/
    ├── fullchain.pem      <-- Tu certificado SSL público (o CA bundle)
    └── privkey.pem        <-- Tu llave SSL privada

Pasos rápidos:

1. Coloca tus certificados en `certs/` con los nombres `fullchain.pem` y `privkey.pem`.
2. Reemplaza `tu-dominio.com` en `nginx/registry.conf` con tu dominio real.
3. Ejecuta:

```bash
cp .env.example .env
# Edit .env to set your domain and ports
docker-compose up -d
```

Uso:

```bash
# Tag
docker tag ruby:2.4.10 tu-dominio.com/ruby-legacy:2.4.10
# Login
docker login tu-dominio.com
# Push
docker push tu-dominio.com/ruby-legacy:2.4.10
```

Notas:
- El servicio `registry` escucha HTTP internamente en el puerto 5000. NGINX termina TLS y actúa como proxy inverso.
- Para producción, usa certificados válidos (Let's Encrypt u otro CA).
