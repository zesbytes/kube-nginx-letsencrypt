#!/bin/sh

if [ -z $EMAIL ] || [ -z $DOMAIN ] || [ -z $SECRET ] || [ -z $CLOUDFLARE_SECRETS_FILE ] || [ -z $KUBERNETES_API_DOMAIN ]; then
	echo "EMAIL, DOMAIN, SECRET, CLOUDFLARE_SECRETS_FILE and KUBERNETES_API_DOMAIN env vars required"
	env
	exit 1
fi

NAMESPACE=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)

certbot certonly -n --agree-tos --email $EMAIL --no-self-upgrade --dns-cloudflare --dns-cloudflare-credentials $CLOUDFLARE_SECRETS_FILE -d $DOMAIN

CERTPATH=/etc/letsencrypt/live/$(echo $DOMAIN | cut -f1 -d',')

ls $CERTPATH || exit 1

cat secret-patch-template.json | \
	sed "s/NAMESPACE/${NAMESPACE}/" | \
	sed "s/NAME/${SECRET}/" | \
	sed "s/TLSCERT/$(cat ${CERTPATH}/fullchain.pem | base64 | tr -d '\n')/" | \
	sed "s/TLSKEY/$(cat ${CERTPATH}/privkey.pem |  base64 | tr -d '\n')/" \
	> secret-patch.json

ls secret-patch.json || exit 1

# update secret
curl -v --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" -k -XPATCH -H "Accept: application/json, */*" -H "Content-Type: application/strategic-merge-patch+json" -d @secret-patch.json https://${KUBERNETES_API_DOMAIN}/api/v1/namespaces/${NAMESPACE}/secrets/${SECRET}
