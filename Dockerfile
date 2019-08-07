FROM pratushnyi/anyphp:ubuntu1804

LABEL maintainer="Pavlo Ratushnyi<pavel.dhq@gmail.com>" 

# Default values
# PHP_VERSION={5.6|7.0|7.1|7.2|7.3}
ARG PHP_VERSION=5.6
# WP_VERSION={4.9.10|5.0.4|5.1.1|5.2.2|latest}
ARG WP_VERSION=latest

# Since image is designed to run tests of wordpress plugin, so keeping next settings simple
ARG MYSQL_USER="root"
ARG MYSQL_PASS="root"
ARG MYSQL_BASE="wp"
ARG WP_DB_TABLE_PREFIX="wp_"
ARG WP_INSTALLATION_DOMAIN="test.com"
ENV WP_INSTALL_DIR="/WP_INSTALL_DIR"
ENV MYSQL_USER=${MYSQL_USER}
ENV MYSQL_PASS=${MYSQL_PASS}
ENV MYSQL_BASE=${MYSQL_BASE}
ENV WP_DB_TABLE_PREFIX=${WP_DB_TABLE_PREFIX}
ENV WP_INSTALLATION_DOMAIN=${WP_INSTALLATION_DOMAIN}

RUN echo Building image with PHP:${PHP_VERSION} and Wordpress:${WP_VERSION}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
        git \
        nano \
        curl \
        zip \
        unzip \
        mysql-server \
        php${PHP_VERSION} \
        php${PHP_VERSION}-mysql \
        php${PHP_VERSION}-cli \
        php${PHP_VERSION}-gd \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-zip \
        php${PHP_VERSION}-dom \
        php${PHP_VERSION}-simplexml \
        php${PHP_VERSION}-xml \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-xdebug && \
        apt-get autoclean -y && \
        apt-get autoremove -y

RUN chown -R mysql:mysql /var/lib/mysql && service mysql start && \
    find /var/lib/mysql -type f -exec touch {} \; && \
    sed -i 's/^bind-address\s*=.*$/bind-address = "0.0.0.0"/' /etc/mysql/my.cnf && \
    sleep 5 && \
    echo "CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASS}';" | mysql && \
    echo "GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_USER}'@'%' WITH GRANT OPTION;" | mysql && \
    echo "CREATE DATABASE ${MYSQL_BASE};" | mysql -u${MYSQL_USER} -p${MYSQL_PASS} && \
    service mysql stop

SHELL ["/bin/bash", "-c"]

# install wpcli
ENV WPCLI="${WP_INSTALL_DIR}/wp-cli.phar --allow-root --path=${WP_INSTALL_DIR}"
ENV WP_PLUGINS_DIR="${WP_INSTALL_DIR}/wp-content/plugins"

RUN chown -R mysql:mysql /var/lib/mysql && \
    service mysql start && \
    mkdir -p ${WP_INSTALL_DIR} && \
    cd ${WP_INSTALL_DIR} && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x ./wp-cli.phar && \
    if [ "latest" = "${WP_VERSION}" ]; then ${WPCLI} core download; else ${WPCLI} core download --version="${WP_VERSION}"; fi && \
    ${WPCLI} config create --dbname=${MYSQL_BASE} --dbuser=${MYSQL_USER} --dbpass=${MYSQL_PASS} --dbprefix=${WP_DB_TABLE_PREFIX} && \
    ${WPCLI} core install --url=${WP_INSTALLATION_DOMAIN} --title=Test --admin_user=wp --admin_password=wp --admin_email=test@wp.org --skip-email && \
    service mysql stop


