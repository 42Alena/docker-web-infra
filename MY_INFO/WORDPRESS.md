##Links

    https://wordpress.org/documentation/

    download:

    https://wordpress.org/download/

    https://developer.wordpress.org/advanced-administration/before-install/howto-install/

    ##PHP
    https://www.php.net/manual/en/install.php 

## Dockerfile

```bash
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
        php7.4-fpm \
        php7.4-mysql \
        mariadb-client \
        wget curl tar unzip \
    && rm -rf /var/lib/apt/lists/*
```
`php7.4-fpm` PHP FastCGI Process Manager (runs WordPress PHP code).

`php7.4-mysql` PHP extension to connect PHP ↔ MariaDB.

`mariadb-client` allows WordPress container to talk to MariaDB.

`wget, curl, tar, unzip`  tools for downloading and unpacking WordPress + wp-cli.

`wget` is a command-line utility for Linux to download files and websites, retrieving content from web servers via HTTP, HTTPS, and FTP.

`rm -rf /var/lib/apt/lists/*`   Cleans up the apt cache.



---

### 💡 What is PHP?

* **PHP** = “Hypertext Preprocessor”.
* It’s a **programming language** mainly used to build websites.
* Unlike HTML (static), PHP is **dynamic** → it can talk to a database, handle forms, create pages on the fly.

---

### 📌 Why do you need PHP in Inception?

* **WordPress is written in PHP.**
* Every WordPress page (blog post, comment, admin dashboard) is **PHP code** that must be executed on the server.
* To run this code, you need a PHP interpreter.

---

### ⚡ What is PHP-FPM?

* FPM = *FastCGI Process Manager*.
* It’s a program that listens for requests on a port (9000 in your setup).
* Nginx cannot run PHP by itself → it only serves static files (HTML, CSS, images).
* So Nginx passes `.php` requests → to PHP-FPM (in the WordPress container).
* PHP-FPM executes the PHP code and sends the result (HTML) back to Nginx → then the browser shows the page.

---

### 🔗 How it fits together

1. You open `https://login.42.fr` in your browser.
2. Nginx (443) receives the request.
3. If it’s a PHP file (like `index.php` from WordPress):

   * Nginx forwards it to **WordPress container** at port 9000.
   * PHP-FPM executes the PHP code.
   * PHP uses **MariaDB** to fetch posts, users, comments.
4. The result (HTML page) goes back through Nginx → to your browser.

---
Instal from oficial install: https://developer.wordpress.org/advanced-administration/before-install/howto-install/

wget https://wordpress.org/latest.tar.gz
Then extract the package using:
tar -xzvf latest.tar.gz

📌 Why /var/www?

/var/www is the standard web root directory on Linux servers.

By putting WordPress files there, later Nginx will serve them.

Subject requires you to mount a volume there (/var/www/wordpress).

tar → archive tool (like .zip but Linux style).

-xzf = three flags combined:

x → extract

z → the file is gzipped (.tar.gz)

f → next argument is the file name (/var/www/latest.tar.gz)

-C /var/www

C = “Change directory before extracting”

-R → recursive (apply to all files inside)

root:root → set both user = root, group = root

## give ownership to www-data:www-data (the web server/PHP user)
chown -R www-data:www-data /var/www/wordpress

Why? Because php-fpm processes run as www-data.

This avoids permission issues when WordPress needs to write files (uploads, plugins, etc.).

## TEst

`docker compose build wordpress`

[+] Building 1/             
 ✔ wordpress  Built     

`docker compose up -d wordpress`

open shell inside container
`docker exec -it wordpress bash`


You are using FROM debian:bookworm → Debian 12.

Debian 12 ships PHP 8.2 packages, not PHP 7.4.

## Right now your Dockerfile ends after unpacking WordPress files.

But you don’t tell Docker what process to keep running.


CMD ["php-fpm8.2", "-F"]

    php-fpm8.2 → starts PHP FastCGI manager

    -F → foreground mode (container stays alive)

## check container

```bash
php-fpm8.2 -v
# -t test
php-fpm8.2 -t

# check WP files
ls -l /var/www/wordpress | head

# -m (modules) This confirms WordPress can talk to MariaDB.
php -m | grep mysql
wget --version
curl --version
tar --version
unzip -v

```
____________
_________________

# Install wp-cli 
## is the command-line interface for WordPress. You can update plugins, configure multisite installations and much more, without using a web browser.
from https://make.wordpress.org/cli/handbook/guides/installing/
```bash
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp
```
Then, check if it works:
(docker exec -it wordpress bash)
` php wp-cli.phar --info`

 `wp --info.` If WP-CLI is installed successfully, you’ll see output like this..
 or 
 docker exec -it wordpress wp --info

 # @Task: you shouldn’t see the WordPress Installation page


 "WordPress Installation page"
When you install WordPress manually:

You visit your site (e.g. http://localhost or https://login.42.fr).

WordPress detects there is no wp-config.php file.

It shows the installation wizard — a form in the browser that asks:

Site title| Admin username | Admin password | Admin email| (Optional) Search engine visibility



 ## COnfig  wp-config.php to not see Wordpress Installation Page from 
 https://developer.wordpress.org/advanced-administration/before-install/howto-install/#the-famous-5-minute-installation 

 "3. (Optional) Find and rename wp-config-sample.php to wp-config.php, then edit the file (see Editing wp-config.php) and add your database information."
 
 ## after install /var/www/wordpresswp-config-sample.php
 Normally (without auto setup)
 ```bash
 root@0925a224b353:/# ls /var/www/wordpress/wp-
wp-activate.php       wp-comments-post.php  wp-cron.php           wp-load.php           wp-settings.php       
wp-admin/             wp-config-sample.php  wp-includes/          wp-login.php          wp-signup.php         
wp-blog-header.php    wp-content/           wp-links-opml.php     wp-mail.php           wp-trackback.php  
root@0925a224b353:/# ls /var/www/wordpress/wp-config-sample.php 
/var/www/wordpress/wp-config-sample.php
root@0925a224b353:/# cat /var/www/wordpress/wp-config-sample.php 
<?php
/**
 * The base configuration for WordPress
 *
```
## 1. copytext from cat /var/www/wordpress/wp-config-sample.php  to my own conf/wp-config.php,
## 2. dockerfile:

```bash
 # Leave the original /var/www/wordpress/wp-config-sample.php  untouched
# make copy from it to own (loaded later, overrides needed settings), to edit config then
COPY  conf/wp-config.php  /var/www/wordpress/
```
## 3. Editing wp-config.php https://developer.wordpress.org/advanced-administration/wordpress/wp-config/
## 4. change config tabase settings (must come from your .env file  )
### 5. change(copy/paste) API KEY in wp-config with: 
root@0925a224b353:/# `curl https://api.wordpress.org/secret-key/1.1/salt/`