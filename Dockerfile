FROM certbot/dns-cloudflare:v0.26.1

RUN apk add --no-cache curl

WORKDIR /tmp

COPY secret-patch-template.json .
COPY entrypoint.sh .

ENTRYPOINT ["./entrypoint.sh"]
