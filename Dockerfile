FROM registry.artifakt.io/php:7.4-fpm

USER root

COPY . /var/www/code

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV ARTIFAKT_PHP_FPM_PORT=9000

WORKDIR /var/www/code

COPY .artifakt/etc/php/zzz-artifakt.ini $PHP_INI_DIR/conf.d/zzz-artifakt.ini

# Copy the artifakt folder on root
RUN  if [ -d .artifakt ]; then cp -rp /var/www/code/.artifakt/ /.artifakt/; fi

# run custom scripts build.sh
# hadolint ignore=SC1091
RUN --mount=source=artifakt-custom-build-args,target=/tmp/build-args \
    if [ -f /tmp/build-args ]; then source /tmp/build-args; fi && \
    if [ -f .artifakt/build.sh ]; then .artifakt/build.sh; fi

RUN --mount=source=artifakt-custom-build-args,target=/tmp/build-args \
    if [ -f /tmp/build-args ]; then source /tmp/build-args; fi && \
    if [ -f .artifakt/composer_setup.sh ]; then .artifakt/composer_setup.sh; fi    

# Define working directory.
WORKDIR /var/www/code

HEALTHCHECK --interval=30s --timeout=3s \
    CMD cgi-fcgi -bind -connect localhost:$ARTIFAKT_PHP_FPM_PORT

CMD ["php-fpm", "-R"]
