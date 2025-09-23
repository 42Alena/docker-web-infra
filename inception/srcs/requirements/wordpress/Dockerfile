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