FROM fedora:24
MAINTAINER Seth Jennings <sethdjennings@gmail.com>

WORKDIR /tmp

RUN dnf install certbot -y && dnf clean all

RUN mkdir /etc/letsencrypt
VOLUME /etc/letsencrypt

COPY secret-patch-template.json .
COPY deployment-patch-template.json .
COPY entrypoint.sh .

CMD ["./entrypoint.sh"]
