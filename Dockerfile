FROM ubuntu:16.04

# SYSTEM UTILIS
RUN apt-get update \
    && apt-get install -y \
        curl \
        apt-utils \
        apt-transport-https \
        debconf-utils \
        gcc \
        build-essential \
        g++-5 \
        apache2 \
        wget \
        mcrypt \
        vim \
        zlib1g-dev \
        libpng-dev \
        zlib1g-dev \
        libpng-dev \
        git \
        zip \
    && rm -rf /var/lib/apt/lists/*

# install necessary locales
RUN apt-get update \
    && apt-get install -y locales \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen

# ONDREJ PPA
RUN apt-get update \
    && apt-get install -y software-properties-common \
        python-software-properties \
    && LC_ALL=C.UTF-8 add-apt-repository -y \
        ppa:ondrej/php

# PHP
RUN apt-get update; \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y -q --force-yes \
        php-mbstring \
        php-pear \
        php-xml \
        php7.1-common \
        php7.1-pdo \
        php7.1-cli \
        php7.1-gd \
        php7.1-bcmath \
        php7.1-mbstring \
        php7.1-zip \
        php7.1-mcrypt \
        php7.1-dev \
        php7.1-xml \
        php7.1-curl \
        php7.1-mysql \
        libapache2-mod-php7.1 \
        unzip \
        lftp \
        --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i 's/memory_limit.*/memory_limit = 256M/' /etc/php/7.1/apache2/php.ini; 

# COPMPOSER
RUN wget https://getcomposer.org/composer.phar \
    && mv composer.phar /usr/bin/composer \
    && chmod +x /usr/bin/composer


RUN curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
# NODE  + GULP
RUN sh -c "echo deb https://deb.nodesource.com/node_10.x cosmic main > /etc/apt/sources.list.d/nodesource.list" \
    && apt-get update \
    && apt-get install -y nodejs \
    && npm install gulp -g

# SUPERVISOR
RUN apt-get update && apt-get install -y supervisor

# CONFIGURE
RUN useradd -d /var/www/html -r -u 1000 app \
    && a2enmod php7.1 \
    && a2enmod headers \
    && a2enmod rewrite  \
    && echo 'date.timezone = "Europe/Warsaw"' >> /etc/php/7.1/apache2/php.ini \
    && echo 'date.timezone = "Europe/Warsaw"' >> /etc/php/7.1/cli/php.ini;

COPY supervisord.conf /etc/supervisord.conf

WORKDIR /var/www/html
VOLUME /var/www/html

ENTRYPOINT /usr/bin/supervisord -c /etc/supervisord.conf
