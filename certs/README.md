# TLS/SSL Certificates

Place your TLS/SSL certificates here with the following names:

- fullchain.pem  -> public certificate (CA bundle)
- privkey.pem    -> private key

Example with Certbot / Let's Encrypt:

sudo certbot certonly --standalone -d your-domain.com
sudo cp /etc/letsencrypt/live/your-domain.com/fullchain.pem ./fullchain.pem
sudo cp /etc/letsencrypt/live/your-domain.com/privkey.pem ./privkey.pem

Note: Make sure to protect the `certs` folder because it contains the private key.
