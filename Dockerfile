# Merged ghost Dockerfile with personal dockerfile that included google storage plugin
# also includes sharp
# https://github.com/docker-library/ghost/blob/master/4/alpine/Dockerfile
FROM docker.io/node:18-alpine3.17 as ghostinstall
ARG GHOST_CLI_VERSION
ARG GHOST_VERSION

ENV GHOST_CLI_VERSION=${GHOST_CLI_VERSION:-1.24.2}
ENV GHOST_VERSION=${GHOST_VERSION:-5.64.0}

ENV NODE_ENV development
ENV GHOST_INSTALL /var/lib/ghost
ENV GHOST_CONTENT /var/lib/ghost/content

RUN apk --no-cache add 'su-exec>=0.2' bash git python3 make g++ vips vips-dev
RUN npm install -g node-gyp npm@latest

RUN set -eux; \ 
    npm install -g "ghost-cli@$GHOST_CLI_VERSION"; \
    npm cache clean --force; \
	mkdir -p "$GHOST_INSTALL"; \
	chown node:node "$GHOST_INSTALL"; \
	\
	su-exec node ghost install "$GHOST_VERSION" --db sqlite3 --no-prompt --no-stack --no-setup --dir "$GHOST_INSTALL"

# Google Cloud Storage
RUN npm install --prefix $GHOST_INSTALL elijahsgh/ghost-google-cloud-storage#dev; \
    npm cache clean --force;
RUN mkdir -p $GHOST_CONTENT/adapters/storage/gcloud
RUN printf "'use strict';\nmodule.exports = require('ghost-google-cloud-storage-new');\n" > $GHOST_CONTENT/adapters/storage/gcloud/index.js

# Google Cloud Storage Official
# RUN npm install --prefix $GHOST_INSTALL --save ghost-google-cloud-storage
# RUN mkdir -p $GHOST_CONTENT/adapters/storage/gcloud
# RUN printf "'use strict';\nmodule.exports = require('ghost-google-cloud-storage');\n" > $GHOST_CONTENT/adapters/storage/gcloud/index.js

#RUN mkdir -p $GHOST_INSTALL/current/content/adapters/storage/gcloud
#RUN printf "'use strict';\nmodule.exports = require('ghost-google-cloud-storage-new');\n" > $GHOST_INSTALL/current/content/adapters/storage/gcloud/index.js

RUN npm install --arch=x64 --platform=linux --libc=musl --prefix "$GHOST_INSTALL" sharp

# Tell Ghost to listen on all ips and not prompt for additional configuration
RUN	set -eux; \
    cd "$GHOST_INSTALL"; \
	su-exec node ghost config --ip '::' --port 2368 --no-prompt --db sqlite3 --url http://localhost:2368 --dbpath "$GHOST_CONTENT/data/ghost.db"; \
	su-exec node ghost config paths.contentPath "$GHOST_CONTENT"; \
	\
# make a config.json symlink for NODE_ENV=development (and sanity check that it's correct)
	su-exec node ln -s "$GHOST_INSTALL/config.development.json" config.production.json; \
	readlink -f "$GHOST_INSTALL/config.development.json"; \
	\
# need to save initial content for pre-seeding empty volumes
	mv "$GHOST_CONTENT" "$GHOST_INSTALL/content.orig"; \
	mkdir -p "$GHOST_CONTENT"; \
	chown node:node "$GHOST_CONTENT"; \
	chmod 1777 "$GHOST_CONTENT"; \
	chown node: -R "$GHOST_INSTALL"

FROM docker.io/node:18-alpine3.17
ENV NODE_ENV production
ENV GHOST_INSTALL /var/lib/ghost
ENV GHOST_CONTENT /var/lib/ghost/content

# libvips is required for sharp
RUN apk --no-cache add vips-dev

COPY --from=ghostinstall $GHOST_INSTALL $GHOST_INSTALL
COPY --from=ghostinstall $GHOST_CONTENT $GHOST_CONTENT

WORKDIR $GHOST_INSTALL
VOLUME $GHOST_CONTENT
EXPOSE 2368
CMD ["node", "current/index.js"]
