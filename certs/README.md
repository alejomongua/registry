# Certificados TLS/SSL

Coloca aquí tus certificados TLS/SSL con los siguientes nombres:

- fullchain.pem  -> certificado público (CA bundle)
- privkey.pem    -> llave privada

Ejemplo con Certbot / Let's Encrypt:

sudo certbot certonly --standalone -d tu-dominio.com
sudo cp /etc/letsencrypt/live/tu-dominio.com/fullchain.pem ./fullchain.pem
sudo cp /etc/letsencrypt/live/tu-dominio.com/privkey.pem ./privkey.pem

Nota: Asegúrate de proteger la carpeta `certs` ya que contiene la llave privada.
