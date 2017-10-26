FROM modpreneur/necktie-fpm:0.16

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

ENV BLACKFIRE_CLIENT_ID=86868e87-ef71-4d80-b099-00eec1203f70
ENV BLACKFIRE_CLIENT_TOKEN=078a0dfe33c4736f9636c2f304969e55f47034cd83d47b41f8acb68891021372
ENV BLACKFIRE_SERVER_ID=527e8db7-a650-4dd2-b65c-27a76e30b989
ENV BLACKFIRE_SERVER_TOKEN=b7009cd33c9b4165c0421bd221557c4c05831fedc7c01474b13253c2f0a488f3

RUN version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/alpine/amd64/$version \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp \
    && mv /tmp/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so \
    && printf "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8707\n" > $PHP_INI_DIR/conf.d/blackfire.ini \
    && mkdir -p /tmp/blackfire \
    && curl -A "Docker" -L https://blackfire.io/api/v1/releases/client/linux_static/amd64 | tar zxp -C /tmp/blackfire \
    && mv /tmp/blackfire/blackfire /usr/bin/blackfire \
    && rm -Rf /tmp/blackfire \
    && chmod o+rwt /tmp \
    && echo "alias blackfire-codecept=\"blackfire run php -n -d extension=pdo_pgsql.so -d extension=pdo_mysql.so -d extension=apcu.so -d extension=apc.so -d extension=mcrypt.so -d apc.enable_cli=1 -d apc.enabled=1  /var/app/vendor/codeception/codeception/codecept\"" >> /root/.config/fish/functions/blackfire-codecept.fish

RUN rm -R /tmp/*

RUN echo "modpreneur/necktie-fpm-dev:0.19" >> /home/versions
