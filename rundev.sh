podman run -it -e paths__contentPath=/var/lib/ghost/content.orig/ -e database__connection__filename=/var/lib/ghost/content.orig/data/ghost.db -p 2368:2368 gcr.io/tamarintech-sites/ghostcms:5.0.0
