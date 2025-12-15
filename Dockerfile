FROM gozargah/marzban:latest

RUN apt-get update && apt-get install -y cron socat curl ca-certificates jq

RUN curl https://get.acme.sh | sh -s email=marz@gmail.com

ARG DOMAIN
ENV DOMAIN=${DOMAIN}

# Устанавливаем переменные окружения для Marzban
ENV XRAY_SUBSCRIPTION_URL_PREFIX = https://$DOMAIN
ENV UVICORN_PORT=443
ENV UVICORN_HOST="0.0.0.0"

WORKDIR /code

COPY xray_config.json ./xray_config.json

RUN xray x25519

RUN openssl rand -hex 8

RUN PRIVATE_KEY=$(xray x25519 | grep 'Private key:' | awk '{print $3}') && \
    SHORT_ID=$(openssl rand -hex 4) && \
    jq --arg pk "$PRIVATE_KEY" --arg sid "$SHORT_ID" \
    '(.inbounds[] | select(.tag == "VLESS TCP REALITY").streamSettings.realitySettings.privateKey) = $pk | (.inbounds[] | select(.tag == "VLESS TCP REALITY").streamSettings.realitySettings.shortIds) = [$sid]' \
    xray_config.json > /tmp/temp_config.json && \
    mv /tmp/temp_config.json xray_config.json

RUN sed -i "s/bind_args\['host'\] = '127.0.0.1'/bind_args['host'] = UVICORN_HOST/g" main.py

EXPOSE 443 444 445 1080