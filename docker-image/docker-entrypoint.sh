#!/bin/bash
set -euo pipefail

echo >&2 "Checking if Wordpress files exists";
if [[ "$1" == apache2* ]] || [ "$1" == php-fpm ]; then
	if [ "$(id -u)" = '0' ]; then
		case "$1" in
			apache2*)
				user="${APACHE_RUN_USER:-www-data}"
				group="${APACHE_RUN_GROUP:-www-data}"

				# strip off any '#' symbol ('#1000' is valid syntax for Apache)
				pound='#'
				user="${user#$pound}"
				group="${group#$pound}"
				;;
			*) # php-fpm
				user='www-data'
				group='www-data'
				;;
		esac
	else
		user="$(id -u)"
		group="$(id -g)"
	fi

    if [ ! -e index.php ] && [ ! -e wp-includes/version.php ]; then
        # if the directory exists and WordPress doesn't appear to be installed AND the permissions of it are root:root, let's chown it (likely a Docker-created directory)
        if [ "$(id -u)" = '0' ] && [ "$(stat -c '%u:%g' .)" = '0:0' ]; then
            chown "$user:$group" .
        fi

        echo >&2 "WordPress not found in $PWD - copying now..."
        if [ -n "$(ls -A)" ]; then
            echo >&2 "WARNING: $PWD is not empty! (copying anyhow)"
        fi
        sourceTarArgs=(
            --create
            --file -
            --directory /usr/src/wordpress
            --owner "$user" --group "$group"
        )
        targetTarArgs=(
            --extract
            --file -
        )
        if [ "$user" != '0' ]; then
            # avoid "tar: .: Cannot utime: Operation not permitted" and "tar: .: Cannot change mode to rwxr-xr-x: Operation not permitted"
            targetTarArgs+=( --no-overwrite-dir )
        fi
        tar "${sourceTarArgs[@]}" . | tar "${targetTarArgs[@]}"
        echo >&2 "Complete! WordPress has been successfully copied to $PWD"
    else
        echo >&2 "Wordpress files found";
    fi
fi

! /usr/local/bin/wp-cli.phar cli update --yes

# if [[ -v XDEBUG ]] && [ "$XDEBUG" = "true" ];
# then
# 	echo "Using XDEBUG";

#     inifile="/usr/local/etc/php/conf.d/pecl-xdebug.ini";
#     extfile="$(find /usr/local/lib/php/extensions/ -name xdebug.so)";
#     remote_port="${XDEBUG_IDEKEY:-9000}";
#     idekey="${XDEBUG_IDEKEY:-xdbg}";

#     if [ -f "$extfile" ] && [ ! -f "$inifile" ];
#     then
#         {
#             echo "[Xdebug]";
#             echo "zend_extension=${extfile}";
#             echo "xdebug.idekey=${idekey}";
#             echo "xdebug.remote_enable=on";
#             echo "xdebug.remote_connect_back=off";
#             echo "xdebug.remote_autostart=on";
#             echo "xdebug.remote_host = host.docker.internal";
#             echo "xdebug.remote_port=${remote_port}";
#         } > $inifile;
#     fi
#     unset extfile remote_port idekey;
#     echo "XDEBUG configured in 9000 port";
# fi

exec "$@"