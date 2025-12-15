FROM gozargah/marzban:latest

RUN mkdir -p /var/lib/marzban/ssl && \
    openssl req -x509 -newkey rsa:4096 \
    -keyout /var/lib/marzban/ssl/key.pem \
    -out /var/lib/marzban/ssl/cert.pem \
    -days 3650 \
    -nodes \
    -subj "/C=RU/ST=Moscow/L=Moscow/O=Marzban/CN=localhost" \
    -addext "subjectAltName=DNS:localhost,DNS:127.0.0.1,IP:127.0.0.1"

# Устанавливаем права доступа
RUN chmod 600 /var/lib/marzban/ssl/key.pem

# Устанавливаем переменные окружения для Marzban
ENV UVICORN_SSL_CERTFILE=/var/lib/marzban/ssl/cert.pem
ENV UVICORN_SSL_KEYFILE=/var/lib/marzban/ssl/key.pem