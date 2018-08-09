FROM certbot/dns-cloudflare:v0.26.1

WORKDIR /tmp

RUN mkdir /etc/letsencrypt
VOLUME /etc/letsencrypt

COPY secret-patch-template.json .
COPY entrypoint.sh .

CMD ["./entrypoint.sh"]
