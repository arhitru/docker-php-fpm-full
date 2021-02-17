# Для начала указываем исходный образ, он будет использован как основа
FROM php:7.4-fpm

# Необязательная строка с указанием автора образа
MAINTAINER arhitru.ru <info@arhitru.ru>

# RUN выполняет идущую за ней команду в контексте нашего образа.
RUN apt-get update -y
RUN apt-get -y install gcc make autoconf libc-dev pkg-config libzip-dev

# В данном случае мы установим некоторые зависимости и модули PHP.
RUN apt-get install -y --no-install-recommends \
	git \
	libmemcached-dev \
	libz-dev \
	libpq-dev \
	libssl-dev libssl-doc libsasl2-dev \
	libmcrypt-dev \
	libxml2-dev \
	zlib1g-dev libicu-dev g++ \
	libldap2-dev libbz2-dev \
	curl libcurl4-openssl-dev \
	libenchant-dev libgmp-dev firebird-dev libib-util \
	re2c libpng++-dev \
	libwebp-dev libjpeg-dev libjpeg62-turbo-dev libpng-dev libxpm-dev libvpx-dev libfreetype6-dev \
	libmagick++-dev \
	libmagickwand-dev \
	zlib1g-dev libgd-dev \
	libtidy-dev libxslt1-dev libmagic-dev libexif-dev file \
	sqlite3 libsqlite3-dev libxslt-dev \
	libmhash2 libmhash-dev libc-client-dev libkrb5-dev libssh2-1-dev \
	unzip libpcre3 libpcre3-dev \
	poppler-utils ghostscript libmagickwand-6.q16-dev libsnmp-dev libedit-dev libreadline6-dev libsodium-dev \
	freetds-bin freetds-dev freetds-common libct4 libsybdb5 tdsodbc libreadline-dev librecode-dev libpspell-dev libonig-dev

# Исправление docker-php-ext-install pdo_dblib
# https://stackoverflow.com/questions/43617752/docker-php-and-freetds-cannot-find-freetds-in-know-installation-directories
RUN ln -s /usr/lib/x86_64-linux-gnu/libsybdb.so /usr/lib/

# Для установки модулей используем команду docker-php-ext-install.
# RUN docker-php-ext-configure hash --with-mhash && \
# 	docker-php-ext-install hash
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
	docker-php-ext-install imap iconv

RUN docker-php-ext-install bcmath bz2 calendar ctype curl dba dom enchant
RUN docker-php-ext-install fileinfo exif ftp gettext gmp
RUN docker-php-ext-install intl json ldap mbstring mysqli
RUN docker-php-ext-install opcache pcntl pspell
RUN docker-php-ext-install pdo pdo_dblib pdo_mysql pdo_pgsql pdo_sqlite pgsql phar posix
RUN docker-php-ext-install readline
RUN docker-php-ext-install session shmop simplexml soap sockets sodium
RUN docker-php-ext-install sysvmsg sysvsem sysvshm
# RUN docker-php-ext-install snmp

# Исправление docker-php-ext-install xmlreader
# https://github.com/docker-library/php/issues/373
RUN export CFLAGS="-I/usr/src/php" && docker-php-ext-install xmlreader xmlwriter xml xmlrpc xsl

RUN docker-php-ext-install tidy tokenizer zend_test zip

# Всё готово к сборке...
# RUN docker-php-ext-install filter reflection spl standard
# RUN docker-php-ext-install pdo_firebird pdo_oci

# Установка расширений pecl
RUN pecl install ds && \
	pecl install imagick && \
	pecl install igbinary && \
	pecl install memcached && \
	pecl install redis-5.1.0 && \
	pecl install mcrypt-1.0.3 && \
	docker-php-ext-enable ds imagick igbinary redis memcached
RUN pecl install mongodb && docker-php-ext-enable mongodb

# https://serverpilot.io/docs/how-to-install-the-php-ssh2-extension
# 	pecl install ssh2-1.1.2 && \
# docker-php-ext-enable ssh2

# Установка xdebug
# RUN pecl install xdebug && docker-php-ext-enable xdebug

RUN yes "" | pecl install msgpack && \
	docker-php-ext-enable msgpack

# Установка APCu
RUN pecl install apcu && \
	docker-php-ext-enable apcu --ini-name docker-php-ext-10-apcu.ini

RUN apt-get update -y && apt-get install -y apt-transport-https locales gnupg

# Установка поддержки MSSQL и драйвера ODBC
# RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
# 	curl https://packages.microsoft.com/config/debian/8/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
# 	export DEBIAN_FRONTEND=noninteractive && apt-get update -y && \
# 	ACCEPT_EULA=Y apt-get install -y msodbcsql unixodbc-dev
# RUN set -xe \
# 	&& pecl install pdo_sqlsrv \
# 	&& docker-php-ext-enable pdo_sqlsrv \
# 	&& apt-get purge -y unixodbc-dev && apt-get autoremove -y && apt-get clean

# RUN docker-php-ext-configure spl && docker-php-ext-install spl

# Установка GD
RUN docker-php-ext-configure gd \
	#	--with-png \
	--with-jpeg \
	--with-xpm \
	--with-webp \
	--with-freetype \
	&& docker-php-ext-install -j$(nproc) gd

# Установка локали utf-8
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

#--------------------------------------------------------------------------
# Последние штрихи
#--------------------------------------------------------------------------

# Установка необходимых библиотеки для проверки работоспособности
RUN apt-get -y install libfcgi0ldbl nano htop iotop lsof cron mariadb-client redis-tools

# Установка composer-а
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
	php -r "if (hash_file('sha384', 'composer-setup.php') === 'e5325b19b381bfd88ce90a5ddb7823406b2a38cff6bb704b0acc289a09c8128d4a8ce2bbafcd1fcbdc38666422fe2806') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
	php composer-setup.php && \
	php -r "unlink('composer-setup.php');" && \
	mv composer.phar /usr/local/sbin/composer && \
	chmod +x /usr/local/sbin/composer

# Установка агента NewRelic
RUN echo 'deb http://apt.newrelic.com/debian/ newrelic non-free' | tee /etc/apt/sources.list.d/newrelic.list && \
	curl https://download.newrelic.com/548C16BF.gpg | apt-key add - && \
	apt-get -y update && \
	DEBIAN_FRONTEND=noninteractive apt-get -y install newrelic-php5 newrelic-sysmond && \
	export NR_INSTALL_SILENT=1 && newrelic-install install

# Установка SendGrid
RUN echo "postfix postfix/mailname string localhost" | debconf-set-selections && \
	echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections && \
	DEBIAN_FRONTEND=noninteractive apt-get install postfix libsasl2-modules -y

# Настройка папки "по-умолчанию"
ADD scripts/* /usr/local/bin/
RUN chmod +x  /usr/local/bin/*

# Добавление конфигурационных файлов
ADD php.ini /usr/local/etc/php/
ADD www.conf /usr/local/etc/php-fpm.d/

# Проверка работоспособности
RUN echo '#!/bin/bash' > /healthcheck && \
	echo 'env -i SCRIPT_NAME=/health SCRIPT_FILENAME=/health REQUEST_METHOD=GET cgi-fcgi -bind -connect 127.0.0.1:9000 || exit 1' >> /healthcheck && \
	chmod +x /healthcheck

# Очистка папок и удаление временных файлов
RUN apt-get remove -y git && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Указываем рабочую директорию для PHP
WORKDIR /var/www

# Запускаем контейнер
CMD ["php-fpm"]
