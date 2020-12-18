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
RUN cd /var/www; \
	unzip analysis.zip; \
	unzip phpcsutils.zip; \ 
	unzip phpcompatibility.zip; \
	unzip vip_cs.zip; \
	unzip wpcs.zip; 
RUN	echo 'alias phpcs="php /var/www/phpcs/bin/phpcs"' >> ~/.bashrc;
RUN	php /var/www/phpcs/bin/phpcs --config-set installed_paths /var/www/phpcs,/var/www/analysis,/var/www/phpcsutils,/var/www/PHPCompatibility,/var/www/vip_cs,/var/www/wpcs;

# WP-CLI
COPY wp-su.sh /usr/local/bin/wp
RUN	curl -o /usr/local/bin/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar; \
	chmod a+x /usr/local/bin/wp-cli.phar; \
	{ \
		echo 'apache_modules:'; \
		echo '  - mod_rewrite'; \
	} > /var/www/wp-cli.yml


# XDebug
RUN cd /var/www; \
	git clone https://github.com/xdebug/xdebug.git;
RUN	cd /var/www/xdebug; \
	phpize;
RUN /var/www/xdebug/./configure --enable-xdebug; \
	make; \
	make install;

### ToDo FUTURO: Install Xdebug manual

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