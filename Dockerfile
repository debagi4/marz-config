FROM gozargah/marzban:latest

ARG DOMAIN
ENV DOMAIN=${DOMAIN}

RUN apt-get update && apt-get install -y cron socat curl ca-certificates

RUN curl https://get.acme.sh | sh -s email=marz@gmail.com

COPY /etc/letsencrypt/live /etc/letsencrypt/live

RUN cd /etc/letsencrypt/live && ls

# Создаем директорию для SSL
RUN mkdir -p /var/lib/marzban/ssl

# Копируем entrypoint скрипт
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Устанавливаем переменные окружения для Marzban
ENV XRAY_SUBSCRIPTION_URL_PREFIX = https://$DOMAIN
ENV UVICORN_SSL_CERTFILE=/var/lib/marzban/ssl/fullchain.pem
ENV UVICORN_SSL_KEYFILE=/var/lib/marzban/ssl/key.pem
ENV UVICORN_PORT=443
ENV UVICORN_HOST="0.0.0.0"

EXPOSE 443