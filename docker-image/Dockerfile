FROM wordpress:latest

# Install the PHP extensions we need
RUN set -ex;\
	apt-get update; \
	apt-get install -y \
		git \
		libzip-dev \
		mariadb-client \
		sudo \
		subversion \
		unzip \
		vim \
	; \
	apt-get install -y \
		--no-install-recommends ssl-cert \
	; \
	rm -rf /var/lib/apt/lists/*; \
	a2enmod ssl; \
	a2ensite default-ssl; \
	docker-php-ext-install zip; 

# Git config
RUN git config --global user.name "WP-DOCKER-PACKAGE Project"; \
	git config --global http.sslVerify false; \
	git config --global user.email "temp@temp.com";

# PHPCS
RUN cd /var/www; \
	git clone https://github.com/squizlabs/PHP_CodeSniffer.git phpcs;
RUN	cd /var/www/phpcs; \
	git pull;
COPY analysis.zip /var/www/analysis.zip
COPY phpcsutils.zip /var/www/phpcsutils.zip
COPY php_compatibility.zip /var/www/phpcompatibility.zip
COPY vip_cs.zip /var/www/vip_cs.zip
COPY wpcs.zip /var/www/wpcs.zip
COPY phpunit.zip /var/www/phpunit.zip
RUN cd /var/www; \
	unzip analysis.zip; \
	unzip phpcsutils.zip; \ 
	unzip phpcompatibility.zip; \
	unzip vip_cs.zip; \
	unzip wpcs.zip; \
	unzip phpunit.zip;
RUN	echo 'alias phpcs="php /var/www/phpcs/bin/phpcs"' >> ~/.bashrc;
RUN	echo 'alias phpunit="php /var/www/phpunit-nightly.phar"' >> ~/.bashrc;
RUN	php /var/www/phpcs/bin/phpcs --config-set installed_paths /var/www/phpcs,/var/www/analysis,/var/www/phpcsutils,/var/www/PHPCompatibility,/var/www/vip_cs,/var/www/wpcs;

# WP-CLI

COPY wp-su.sh /usr/local/bin/wp
COPY wp-cli.zip /usr/local/bin/wp-cli.zip
RUN  cd /usr/local/bin; \
	 unzip wp-cli.zip; \
	 chmod a+x /usr/local/bin/wp-cli.phar; \
	 { \
		echo 'apache_modules:'; \
		echo '  - mod_rewrite'; \
	 } > /var/www/wp-cli.yml; \
	 wp;

# Memcached extension (https://pecl.php.net/package/memcache)
COPY memcache-8.0.zip /var/www/memcache.zip
RUN cd /var/www; \
	unzip memcache.zip; \
	cd /var/www/memcache-8.0; \
	phpize; \
	./configure; \
	make; \
	make install;

# XDebug
RUN cd /var/www; \
	git clone https://github.com/xdebug/xdebug.git;
RUN	cd /var/www/xdebug; \
	phpize;
RUN /var/www/xdebug/./configure --enable-xdebug; \
	make; \
	make install;

### ToDo FUTURO: Node + libraries + Gulp

WORKDIR /var/www/html
VOLUME /var/www/html

# Change www-data user to match the host system UID and GID and chown www directory
RUN usermod --non-unique --uid 1000 www-data \
  && groupmod --non-unique --gid 1000 www-data \
  && chown -R www-data:www-data /var/www
EXPOSE 80 443

# Overrides wp docker default entrypoint
COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["apache2-foreground"]
