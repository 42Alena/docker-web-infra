FROM debian:bookworm

RUN apt-get update -y && apt-get upgrade -y 


RUN apt-get update && apt-get upgrade -y && \
	apt-get install -y php8.2-fpm \
	php8.2-mysql \    
	mariadb-client \
	wget curl tar unzip \
	&& rm -rf /var/lib/apt/lists/*

# @Task: php-fpm only (no nginx), 
# https://www.php.net/downloads.php?usage=web&os=linux&osvariant=linux-debian&version=8.2
RUN wget https://wordpress.org/latest.tar.gz -P /var/www \
	&& tar -xzf /var/www/latest.tar.gz -C /var/www \
	&& rm /var/www/latest.tar.gz \
	&& chown -R root:root /var/www/wordpress


# https://make.wordpress.org/cli/handbook/guides/installing/
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp


# Leave the original /var/www/wordpress/wp-config-sample.php  untouched
# make copy from it to own (loaded later, overrides needed settings), to edit config then
COPY  conf/wp-config.php  /var/www/wordpress/

CMD ["php-fpm8.2", "-F"]