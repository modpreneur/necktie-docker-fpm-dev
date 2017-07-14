FROM modpreneur/necktie-fpm:0.13

MAINTAINER Martin Kolek <kolek@modpreneur.com>

#RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories \
#    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories

RUN apk add --update \
    nano \
    nodejs \
    nodejs-npm \
    fish

ENV TERM xterm

RUN echo "max_execution_time=60" >> /usr/local/etc/php/php.ini \
    && echo "error_log = /var/log/php.errors" >> /usr/local/etc/php/php.ini \
    && docker-php-ext-install pcntl iconv\
    && npm install -g less \
    && npm install -g webpack  --save-dev \
    && npm install -g uglifycss \
    && npm install -g eslint eslint-plugin-react \
    && composer global require "hirak/prestissimo:^0.3" \
    #phpunit is install with codeception
    && composer global require codeception/codeception

RUN mkdir -p /root/.config/fish/functions \
    && echo "alias codecept=\"php -n -d extension=pdo_pgsql.so -d extension=pdo_mysql.so -d extension=apcu.so -d extension=apc.so -d extension=mcrypt.so -d apc.enable_cli=1 -d apc.enabled=1  /var/app/vendor/codeception/codeception/codecept\"" >> /root/.config/fish/functions/codecept.fish

# comment to test if it failing tests
# ADD colors.fish /root/.config/fish/colors.fish

RUN pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && echo "xdebug.remote_enable=1" >> /usr/local/etc/php/php.ini \
    && echo "xdebug.remote_port=9000" >> /usr/local/etc/php/php.ini \
    && echo "xdebug.idekey=PHPSTORM" >> /usr/local/etc/php/php.ini \
    && echo "xdebug.remote_connect_back=1" >> /usr/local/etc/php/php.ini \
    && echo "xdebug.profiler_enable=0" >> /usr/local/etc/php/php.ini \
    && echo "xdebug.profiler_output_dir=/var/app/var/xdebug/" >> /usr/local/etc/php/php.ini \
    && echo "xdebug.profiler_enable_trigger=1" >> /usr/local/etc/php/php.ini \
    && echo "alias composer=\"php -n -d memory_limit=2048M -d extension=bcmath.so -d extension=zip.so /usr/bin/composer\"" >> /root/.config/fish/functions/composer.fish

RUN echo "modpreneur/necktie-fpm-dev:0.15" >> /home/versions
