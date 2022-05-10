podman run --rm -it \
	-p 2368:2368 \
	-v $(pwd)/config.production.json:/var/lib/ghost/config.production.json \
	-e NODE_ENV=production \
	-e logging__transports='["stdout"]' \
	-e logging__level=info \
	-e server__host=0.0.0.0 \
	-e storage__active="gcloud" \
    -e database__client=mysql \
	-e database__connection__host=192.168.86.28 \
	-e database__connection__user=root \
	-e database__connection__password=my-secret-pw \
	-e database__connection__database=ghostcms \
	newghostcms $@
#	gcr.io/tamarintech-sites/newghostcms:latest $@

#	-e database__client=sqlite3 \
#	-e database__connection__filename="content/data/ghost-test.db" \
