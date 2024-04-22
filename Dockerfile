FROM php:8.1-cli
LABEL maintainer="Quintus Leung"

WORKDIR /app

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
RUN apt-get update && apt-get install -y \
		git \
		curl \
		libicu-dev \
		libxml2-dev \
		libzip-dev \
		libcurl4-openssl-dev \
		libfreetype-dev \
		libjpeg62-turbo-dev \
		libpng-dev \
	&& docker-php-ext-install gd bcmath curl zip

ENV PATH="/root/.composer/vendor/bin:$PATH"
ENV COMPOSER_ALLOW_SUPERUSER=1

# Drush

RUN composer global require symfony/http-kernel -W && \
    composer global require drupal/core && \
    composer global require drush/drush && \
    composer global update
RUN ln -s /root/.composer/vendor/bin/drush /usr/local/bin/drush

# Pantheon terminus
RUN curl -L https://github.com/pantheon-systems/terminus/releases/download/3.3.3/terminus.phar --output /usr/local/bin/terminus
RUN chmod +x /usr/local/bin/terminus
RUN /usr/local/bin/terminus self:update

# Nodejs
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs

# Playwright
RUN npm install --global playwright typescript @types/node toml @playwright/test && \
    playwright install --with-deps
    
# Artillery
RUN npm install --global artillery

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
