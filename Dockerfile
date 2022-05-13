# Merged ghost Dockerfile with personal dockerfile that included google storage plugin
# also includes sharp
# https://github.com/docker-library/ghost/blob/master/4/alpine/Dockerfile
FROM docker.io/node:14-alpine as ghostinstall
ENV GHOST_CLI_VERSION 1.19.3
ENV GHOST_VERSION 4.47.1

ENV NODE_ENV development
ENV GHOST_INSTALL /var/lib/ghost
ENV GHOST_CONTENT /var/lib/ghost/content

RUN apk --no-cache add 'su-exec>=0.2' bash git python3 make g++ vips vips-dev
RUN npm install -g node-gyp

RUN set -eux; \ 
    npm install -g "ghost-cli@$GHOST_CLI_VERSION"; \
    npm cache clean --force

RUN set -eux; \
	mkdir -p "$GHOST_INSTALL"; \
	chown node:node "$GHOST_INSTALL"; \
	\
	su-exec node ghost install "$GHOST_VERSION" --db sqlite3 --no-prompt --no-stack --no-setup --dir "$GHOST_INSTALL";

# Google Cloud Storage
RUN npm install --prefix $GHOST_INSTALL elijahsgh/ghost-google-cloud-storage#dev \
    npm cache clean --force; \
    echo 2;

RUN mkdir -p $GHOST_CONTENT/adapters/storage/gcloud
RUN printf "'use strict';\nmodule.exports = require('ghost-google-cloud-storage-new');\n" > $GHOST_CONTENT/adapters/storage/gcloud/index.js
#RUN mkdir -p $GHOST_INSTALL/current/content/adapters/storage/gcloud
#RUN printf "'use strict';\nmodule.exports = require('ghost-google-cloud-storage-new');\n" > $GHOST_INSTALL/current/content/adapters/storage/gcloud/index.js

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
	\
# force install "sqlite3" manually since it's an optional dependency of "ghost"
# (which means that if it fails to install, like on ARM/ppc64le/s390x, the failure will be silently ignored and thus turn into a runtime error instead)
# see https://github.com/TryGhost/Ghost/pull/7677 for more details
	cd "$GHOST_INSTALL/current"; \
# scrape the expected version of sqlite3 directly from Ghost itself
	sqlite3Version="$(node -p 'require("./package.json").optionalDependencies["sqlite3"]')"; \
	[ -n "$sqlite3Version" ]; \
	[ "$sqlite3Version" != 'undefined' ]; \
	if ! su-exec node yarn add "sqlite3@$sqlite3Version" --force; then \
# must be some non-amd64 architecture pre-built binaries aren't published for, so let's install some build deps and do-it-all-over-again
		apk add --no-cache --virtual .build-deps g++ gcc libc-dev make python2 vips-dev; \
		\
		npm_config_python='python2' su-exec node yarn add "sqlite3@$sqlite3Version" --force --build-from-source; \
		\
		apk del --no-network .build-deps; \
	fi; \
	\
	su-exec node yarn cache clean; \
	su-exec node npm cache clean --force; \
	npm cache clean --force; \
	rm -rv /tmp/yarn* /tmp/v8*

RUN su-exec node npm install --prefix "$GHOST_INSTALL" sharp


FROM docker.io/node:14-alpine
ENV NODE_ENV production
ENV GHOST_INSTALL /var/lib/ghost
ENV GHOST_CONTENT /var/lib/ghost/content

# libvips is required for sharp
RUN apk --no-cache add vips

COPY --from=ghostinstall $GHOST_INSTALL $GHOST_INSTALL
COPY --from=ghostinstall $GHOST_CONTENT $GHOST_CONTENT

WORKDIR $GHOST_INSTALL
VOLUME $GHOST_CONTENT
EXPOSE 2368
CMD ["node", "current/index.js"]
