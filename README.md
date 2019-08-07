# docker-wordpress-test-image [![Build Status](https://travis-ci.org/paveldhq/docker-wordpress-test-image.svg?branch=master)](https://travis-ci.org/paveldhq/docker-wordpress-test-image)


Dockerfile designed to be a middleware for test execution with different environments:
 * PHP version
 * Wordpress version

For usage in `Dockerfile` use:

```
ARG PHP_VER=7.3
ARG WP_VER=latest
FROM pratushnyi/ubuntu-wp-test:php-${PHP_VER}-wp-${WP_VER}

...
```

Image contents:
  * PHP and WP in selected versions
  * MySQL with user `root` password `root` and database `wp`
  * Wordpress installed in `$WP_INSTALL_DIR`
  * `wp-cli.phar` in `$WP_INSTALL_DIR`, accessible by `WPCLI`
  * `$WP_PLUGINS_DIR` leads to `"${WP_INSTALL_DIR}/wp-content/plugins"`
 
