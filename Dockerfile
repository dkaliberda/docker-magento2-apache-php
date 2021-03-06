FROM php:7.2-apache
MAINTAINER Fabrizio Balliano <fabrizio@fabrizioballiano.com>

RUN apt-get update \
  && apt-get install -y \
    libfreetype6-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libxslt1-dev \
    librabbitmq-dev \
    libssh-dev \
    git \
    vim \
    unzip \
    wget \
    lynx \
    psmisc \
    redis-tools \
  && apt-get clean

RUN docker-php-ext-configure \
    gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/; \
  docker-php-ext-install \
    gd \
    intl \
    mbstring \
    pdo_mysql \
    xsl \
    zip \
    opcache \
    bcmath \
    soap \
    sockets \
  && pecl install amqp \
  && docker-php-ext-enable amqp

ADD php.ini /usr/local/etc/php/conf.d/888-fballiano.ini
ADD register-host-on-redis.sh /register-host-on-redis.sh
ADD unregister-host-on-redis.sh /unregister-host-on-redis.sh
ADD start.sh /start.sh

RUN usermod -u 1000 www-data; \
  a2enmod rewrite expires remoteip; \
  echo "RemoteIPHeader X-Real-IP" >> /etc/apache2/conf-available/docker-php.conf; \
  curl -o /tmp/composer-setup.php https://getcomposer.org/installer; \
  curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig; \
  php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }"; \
  php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer; \
	rm /tmp/composer-setup.php; \
  chmod +x /usr/local/bin/composer; \
  curl -o n98-magerun2.phar https://files.magerun.net/n98-magerun2.phar; \
  chmod +x ./n98-magerun2.phar; \
  chmod +x /register-host-on-redis.sh; \
  chmod +x /unregister-host-on-redis.sh; \
  chmod +x /start.sh; \
  mv n98-magerun2.phar /usr/local/bin/; \
  mkdir -p /root/.composer

ENTRYPOINT ["/start.sh"]
