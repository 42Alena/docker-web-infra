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
```

You are using FROM debian:bookworm → Debian 12.

Debian 12 ships PHP 8.2 packages, not PHP 7.4.