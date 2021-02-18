# docker-php-fpm-full
Готовый к работе полностью настроенный образ PHP-FPM для докера, который может использоваться в любых проектах на PHP. Образ тяжёлый. Цель состоит в том, чтобы поддерживать максимальное количество функций из коробки, которые можно было бы легко включить / выключить с помощью настроек среды.

Переменные среды
<br>
Используйте следующие переменные среды для настройки контейнера 
<br>
<code>
PHP_UID=1000</code>
<br>
<code>PHP_GID=1000</code>
<br>
<code>PHP_HOME=/app</code>
<br>
<code>PHP_USER=php-fpm</code>
<br>
Cоздаёт пользователя с именем php-fpm с UID:GUID 1000:1000 и домашним каталогом /app, на которого затем можно будет ссылаться в файле конфигурации php-fpm

<code>PHP_INI_PATH=/path/to/php.ini</code>
<br>
включит указанную конфигурацию php.ini во время запуска php-fpm

<code>PHP_POOL_PATH=/path/to/pool.conf</code>
<br>
включит указанную конфигурацию pool.conf при запуске php-fpm. Если вы не укажете путь к вашему пользовательскому www.conf, будет загружена конфигурация www.conf по умолчанию.

<code>PHP_BOOT_SCRIPTS=/path/to/*.sh</code>
<br>
запустит сценарии по указанному пути во время загрузки контейнера, до запуска php-fpm. Полезно в случаях, когда вы хотите включить несколько конфигураций пулов, где каждый пул использует своего пользователя системы (общий хостинг). В этих случаях вам нужно будет создать каждого пользователя системы до запуска менеджера php-fom. PHP_BOOT_SCRIPTS можно использовать для указания на сценарий bash, который будет создавать этих системных пользователей.

<code>NEWRELIC_LICENSE=license_string</code>
<br>
включит расширение NewRelic для мониторинга производительности приложения PHP.

<code>SENDGRID_API_KEY=api_key_string</code>
<br>
меняет отправку электронной почты по умолчанию на SendGrid. Google Cloud блокирует SMTP-порт 25 по умолчанию, поэтому это может быть полезным решением для настройки альтернативной маршрутизации электронной почты до запуска менеджера php-fpm..

<code>TEST_EMAIL=email@domain.com</code>
<br>
если установлено, при загрузке контейнера тестовый скрипт отправит электронное письмо с использованием почтовой функции PHP на указанный адрес получателя.

<code>PHP_SESSION_HANDLER=php_session_handler</code>
<br>
<code>PHP_SESSION_PATH=php_session_path</code>
<br>
для поддержки обработчиков сессий PHP в Redis или Memcached. Обновит обработчик сеанса PHP по умолчанию. Полезно в кластерных средах, чтобы разрешить общие сеансы PHP между экземплярами кластера.

[Пример для Redis](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-redis-server-as-a-session-handler-for-php-on-ubuntu-14-04)
<br>
<code>PHP_SESSION_HANDLER=redis</code>
<br>
<code>PHP_SESSION_PATH=tcp://redis.host:6379</code>
<br>
укажет обработчику глобального сеанса php.ini использовать сервер Redis по имени redis.host с портом 6379.

[Пример для Memcached](https://www.digitalocean.com/community/tutorials/how-to-share-php-sessions-on-multiple-memcached-servers-on-ubuntu-14-04)
<br>
<code>PHP_SESSION_HANDLER=memcached</code>
<br>
<code>PHP_SESSION_PATH=memcached.host:11211</code>
<br>
зукажет обработчику глобального сеанса php.ini использовать сервер Memcached по имени memcached.host с портом 11211.

<code>SUPERVISORD_PATH=/path/to/supervisord.conf</code>
<br>
Позволяет контролировать и отслеживать несколько процессов, запущенных внутри контейнера.
<br>
Обратите внимание, что если вы используете supervisord, сценарий загрузки контейнера создаст файл / healthcheck для мониторинга основного процесса supervisord, который можно использовать для мониторинга состояния контейнера. Этот пример конфигурации для docker-compose.yaml гарантирует, что контейнер не выйдет после загрузки, и перенаправит журналы супервизора в стандартный вывод.

    command: [ "tail", '-f', '/var/log/supervisor/supervisord.log' ]
    healthcheck:
      test: /healthcheck
      retries: 3
      timeout: 5s
      interval: 5s

<code>PHP_ACCESS_LOG=off</code>
<br>
отключает журналирование доступа к контейнеру php.

<code>PHP_ERROR_LOG=on</code>
<br>
включает журналирование ошибок.

Установленные расширения
- apc
- apcu
- bcmath
- bz2
- calendar
- Core
- ctype
- curl
- date
- dba
- dom
- ds
- enchant
- exif
- fileinfo
- filter
- ftp
- gd
- gettext
- gmp
- hash
- iconv
- igbinary
- imagick
- imap
- interbase
- intl
- json
- ldap
- libxml
- mbstring
- memcache
- memcached
- mongodb
- msgpack
- mysqli
- mysqlnd
- newrelic
- openssl
- pcntl
- pcre
- PDO
- pdo_dblib
- pdo_mysql
- pdo_pgsql
- pdo_sqlite
- pdo_sqlsrv
- pgsql
- Phar
- posix
- pspell
- readline
- recode
- redis
- Reflection
- session
- shmop
- SimpleXML
- soap
- sockets
- sodium
- SPL
- sqlite3
- ssh2
- standard
- sysvmsg
- sysvsem
- sysvshm
- test
- tidy
- tokenizer
- wddx
- xdebug
- xml
- xmlreader
- xmlrpc
- xmlwriter
- xsl
- Zend OPcache
- zip
- zlib

Запуск приложения PHP
<br>
<code>docker run -it --name php-fpm -v /path/to/your/app:/app crunchgeek/php-fpm:7.2 php script.php</code>
<br>
Docker Compose:

    version: '3'
       services:
          php-fpm:
             container_name: php-fpm
             image: arhitru/php-fpm-full
             entrypoint: php index.php
             volumes:
                - /path/to/your/app:/app

Заапуск сервера:
<br>
<code>docker run --rm --name php-fpm -v /path/to/your/app:/app -p 8000:8000 arhitru/php-fpm-full php -S 0.0.0.0:8000 /app/index.php</code>

<code>docker run --rm -it arhitru/php-fpm-full php -m</code>
<br>
сыводит список установленных расширений

Extensions that failed to build from 7.3 to 7.4:
- mhash (Implemented RFC: The hash extension is now an integral part of PHP and cannot be disabled)
- interbase (Unbundled the InterBase extension and moved it to PECL)
- recode (Unbundled the recode extension)
- wddx (Deprecated and unbundled the WDDX extension)
- docker-php-ext-configure gd --with-png только PNG
