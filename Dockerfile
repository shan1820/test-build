############################################################
# Dockerfile to build WCMS container images
# Based on Ubuntu Bionic
############################################################

# Set the base image to Ubuntu
FROM ubuntu:bionic

# Allows installing of packages without prompting the user to answer any questions
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install --assume-yes \
    software-properties-common \
    language-pack-en \
    curl \
    apt-transport-https

## Add the repo to get the latest PHP versions
RUN export LANG=en_US.UTF-8

## Need LC_ALL= otherwise adding the repos throws an ascii error.
RUN LC_ALL=en_US.UTF-8 add-apt-repository -y ppa:ondrej/php

## Add the git repo so we can get the latest git (we need 2.9.2+)
RUN add-apt-repository ppa:git-core/ppa

# Added so we can install 6.x branch of nodejs.
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -

RUN apt-get update

# Install packages.
RUN apt-get install -y \
    vim \
    git \
    apache2 \
    php5.6 \
    php5.6-apc \
    php5.6-fpm \
    php5.6-xml \
    php5.6-simplexml \
    php5.6-mbstring \
    php5.6-cli \
    php5.6-mysql \
    php5.6-gd \
    php5.6-curl \
    php5.6-ldap \
    php5.6-mcrypt \
    php5.6-zip \
    php-pear \
    php-xdebug \
    libapache2-mod-php5.6 \
    optipng \
    jpegoptim \
    imagemagick \
    curl \
    nano \
    mysql-client \
    openssh-server \
    wget \
    ruby-sass \
    ruby-compass \
    nodejs=6.14.1-1nodesource1 \
    dos2unix \
    supervisor \
    sudo \
    gcc-6-base \
    libasound2

## pdftk is no longer part of Ubuntu 18.04 repo to add it:
RUN wget http://ftp.br.debian.org/debian/pool/main/p/pdftk/pdftk_2.02-4+b2_amd64.deb && \ 
    wget http://ftp.br.debian.org/debian/pool/main/g/gcc-defaults/libgcj-common_6.3-4_all.deb && \ 
    wget http://ftp.br.debian.org/debian/pool/main/g/gcc-6/libgcj17_6.3.0-18+deb9u1_amd64.deb && \ 
    dpkg -i pdftk_2.02-4+b2_amd64.deb libgcj17_6.3.0-18+deb9u1_amd64.deb libgcj-common_6.3-4_all.deb

RUN apt-get clean

## enable apache2 mods that we need
RUN a2enmod rewrite \
    ssl \
    proxy_http \
    proxy_fcgi

## for Content Security Policy (CSP).
RUN a2enmod headers

## enable mcrypt
RUN phpenmod mcrypt

## add upload progress
RUN apt-get install php-uploadprogress

# Install Composer.
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

## Make sure we are running php we selected
RUN update-alternatives --set php /usr/bin/php5.6
RUN a2enmod php5.6
