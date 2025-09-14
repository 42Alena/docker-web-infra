# Inception – Docker & Docker Compose Commands (Exam-Ready)

**Legend:** 🐳 Image · ▶️ Run/Exec · 📦 Container · 📂 Volume · 🌐 Network · ⚙️ Compose · 🧹 Cleanup · 🔎 Inspect · ☠️ Danger (destructive)

## 🔗 Navigation

- [🐳 Images (build & manage)](#toc-images)
- [📦 Containers (quick tests & debugging)](#toc-containers)
- [📂 Volumes (persistence requirements)](#toc-volumes)
- [🌐 Networks (service isolation & reachability)](#toc-networks)
- [⚙️ Docker Compose (the main workflow)](#toc-compose)
- [🔐 TLS / 443 only – quick proves](#toc-tls)
- [☠️ Danger Zone – Full Cleanup / Reset](#toc-danger)
- [📘 Command & Flag Reference – Inception Defense](#toc-reference)


---

<a id="toc-images"></a>
## 🐳 Images (build & manage)
 
Docker **images** are blueprints for containers. You must build your own for NGINX, MariaDB, and WordPress, using Alpine or Debian penultimate. These commands handle image creation, listing, and deletion.  

|Sign|Command|What it does|When (Inception)|Flags decoded|Pitfalls / Defense checks|
|---|---|---|---|---|---|
|🐳|`docker build -t nginx .`|Builds image from `Dockerfile` in `.` and names it `nginx`.|Build **nginx/wordpress/mariadb** images.|`-t` = **tag** (human name)|Run inside `srcs/requirements/<svc>/`. Must be Alpine/Debian penultimate. |
|🔎|`docker images`|Lists local images.|Verify images carry the **same name as service**.|—|`<none>` tag? You forgot `-t`.|
|☠️|`docker rmi -f <img>`|Removes an image.|Force fresh rebuild if cache is wrong.|`-f` = **force**|Remove dependent containers first.|
|☠️|`docker rmi -f $(docker images -qa)`|Removes **all images**.|Use for full reset before defense.|`-q` = IDs only · `-a` = all|Everything must be rebuilt after.|

---

<a id="toc-containers"></a>
## 📦 Containers (quick tests & debugging)
 
Containers are **running instances** of images. These commands help you run, stop, remove, or enter containers. During defense, you’ll prove 3 services are running (nginx, mariadb, wordpress).  

|Sign|Command|What it does|When (Inception)|Flags decoded|Pitfalls / Defense checks|
|---|---|---|---|---|---|
|▶️|`docker run -it nginx`|Starts a container; opens interactive TTY.|Smoke-test NGINX before Compose.|`-i` interactive, `-t` TTY|Exits when PID 1 ends; don’t hack with `tail -f`. |
|📦|`docker ps`|Shows **running** containers.|Prove 3 services are up (mandatory).|—|Names should match services.|
|📦|`docker ps -a`|Shows **all** (incl. exited).|Find crashes after start.|—|Check **Exit Code** quickly.|
|📦|`docker stop <id>`|Graceful stop.|Free ports 443/3306/9000 before re-run.|—|Stop before `rm`.|
|📦|`docker rm <id>`|Remove stopped container.|Clean failed attempts.|—|Use `ps -a` to list IDs.|
|☠️|`docker stop $(docker ps -qa)`|Stops **all containers**.|Pre-defense reset.|`-q` IDs only · `-a` all|Kills everything at once.|
|☠️|`docker rm $(docker ps -qa)`|Removes **all containers**.|Clean system state.|—|Leaves only images/volumes.|
|▶️|`docker exec -it nginx bash`|Shell **inside** running container.|Inspect `/etc/nginx`, `/var/www/wordpress`, `/var/lib/mysql`.|`-i` interactive, `-t` TTY|On Alpine, use `sh` if `bash` missing.|
▶️|`docker run -it --rm mariadb bash`|Start a new container just for testing| -it → interactive + terminal.--rm → auto-remove the container when you exit | This is good for temporary test containers|

---

<a id="toc-volumes"></a>
## 📂 Volumes (persistence requirements)
 
Volumes are **storage on host** that survive container restarts. You must mount MariaDB + WordPress volumes into `/home/<login>/data/...`.  

|Sign|Command|What it does|When (Inception)|Flags decoded|Pitfalls / Defense checks|
|---|---|---|---|---|---|
|📂|`docker volume ls`|Lists volumes.|Confirm `wordpress` and `mariadb` exist.|—|Names often prefixed by compose project.|
|🔎|`docker volume inspect <vol>`|Shows host mountpoint.|Must be `/home/<login>/data/...`.|—|Fix compose if wrong path.|
|☠️|`docker volume rm <vol>`|Deletes a volume (data loss).|Hard reset DB or WP files.|—|Irreversible wipe.|
|☠️|`docker volume rm $(docker volume ls -q)`|Deletes **all volumes**.|Full persistence wipe.|`-q` IDs only|Nukes DB + site files.|

---

<a id="toc-networks"></a>
## 🌐 Networks (service isolation & reachability)
 
Networks allow containers to talk. You must create a **bridge network** where nginx, mariadb, wordpress are connected.  

|Sign|Command|What it does|When (Inception)|Flags decoded|Pitfalls / Defense checks|
|---|---|---|---|---|---|
|🌐|`docker network ls`|Lists networks.|Show custom compose network exists.|—|No `network: host` allowed. |
|🔎|`docker network inspect inception`|Shows members, subnets, IPs.|Prove all 3 containers share one network.|—|Check container list.|
|☠️|`docker network rm inception`|Removes a network.|Reset misconfig.|—|Detach containers first.|
|☠️|`docker network rm $(docker network ls -q)`|Removes **all networks**.|Full reset.|May warn on defaults.|

---

<a id="toc-compose"></a>
## ⚙️ Docker Compose (the main workflow)
 
Docker Compose manages **multi-container infra**. This is the core of Inception. All services (nginx, mariadb, wordpress) must be declared in `docker-compose.yml`.  

|Sign|Command|What it does|When (Inception)|Flags decoded|Pitfalls / Defense checks|
|---|---|---|---|---|---|
|⚙️|`docker compose up -d`|Build (if needed) & start services.|Normal start.|`-d` = detached|Should expose only **443**. |
|⚙️|`docker compose up -d --build`|Force rebuild then start.|After changes.|`--build` = rebuild images|Faster than manual build.|
|⚙️|`docker compose ps`|Lists compose containers.|Confirm 3 running.|—|Must match services.|
|⚙️|`docker compose logs -f`|Live logs.|Debug init errors.|`-f` = follow|Ctrl+C exits logs only.|
|⚙️|`docker compose stop`|Stops services, keeps volumes.|Pause system.|—|Keeps DB/site.|
|⚙️|`docker compose down`|Stops + removes containers/networks, keeps volumes.|Clean reset.|—|Use before changing networks.|
|⚙️|`docker compose down -v`|Also deletes volumes.|Fresh install.|`-v` = volumes|Mandatory before eval.|

---

<a id="toc-tls"></a>
## 🔐 TLS / 443 only – quick proves
 
TLS/HTTPS is **mandatory**: only port 443 allowed, TLS v1.2/v1.3 must work. These commands prove your setup.  

|Sign|Command|What it does|When (Inception)|Flags decoded|Pitfalls / Defense checks|
|---|---|---|---|---|---|
|🔎|`curl -kI https://<login>.42.fr`|HEAD request, ignore cert errors.|Show NGINX answers on 443 only.|`-k` = ignore SSL, `-I` = headers only|HTTP 80 must fail.|
|🔎|`openssl s_client -connect <login>.42.fr:443 -tls1_2`|Manual TLS handshake.|Prove TLS v1.2/1.3 works.|`-connect` host:port · `-tls1_2`|Subject requires v1.2 or v1.3.|

---

<a id="toc-danger"></a>
## ☠️ Danger Zone – Full Cleanup / Reset
 
This is the **nuke-all** area. Use it before defense. It removes containers, images, volumes, and networks. After this, evaluator runs your Makefile to rebuild everything.  

|Sign|Command|What it does|What it cleans|
|---|---|---|---|
|☠️|`docker stop $(docker ps -qa)`|Stop all containers.|Running containers (services stop).|
|☠️|`docker rm $(docker ps -qa)`|Remove all containers.|Stopped containers.|
|☠️|`docker rmi -f $(docker images -qa)`|Remove all images.|All local images (nginx/wp/mariadb).|
|☠️|`docker volume rm $(docker volume ls -q)`|Remove all volumes.|DB + WP files (persistence wiped).|
|☠️|`docker network rm $(docker network ls -q)`|Remove all networks.|Custom bridge networks.|
|☠️|`docker system prune -af`|Delete unused objects.|Dangling images, stopped containers, caches.|

👉 **Result:** system is empty → only base Docker remains. Perfect clean state for defense.

---

<a id="toc-reference"></a>
## 📘 Command & Flag Reference – Inception Defense
 
This is a **dictionary** for all flags and commands used. You can explain any option (`-q`, `-a`, `-f`, `--build`) to evaluators.  

|Command / Flag|Meaning|Example in use|Why it matters in Inception|
|---|---|---|---|
|`docker build`|Build an image from a Dockerfile.|`docker build -t nginx .`|Create custom service images.|
|`-t` (tag)|Assign name/tag.|`docker build -t mariadb .`|Images = service names.|
|`.` (dot)|Current folder as context.|`docker build .`|Must run in correct service folder.|
|`docker images`|List local images.|`docker images`|Verify builds.|
|`docker rmi`|Remove image(s).|`docker rmi -f nginx`|Rebuild clean.|
|`-f` (force)|Skip confirmation.|`docker rmi -f <id>`|Required for used images.|
|`$( ... )`|Command substitution.|`$(docker images -qa)`|One-liners in cleanup.|
|`-q` (quiet)|IDs only.|`docker ps -q`|Used in mass cleanup.|
|`-a` (all)|Include all.|`docker ps -a`|Show stopped too.|
|`docker run`|Start new container.|`docker run -it nginx`|Quick test of image.|
|`-i` (interactive)|Keep STDIN open.|`docker run -i`|Needed for debugging.|
|`-t` (tty)|Allocate terminal.|`docker run -it`|Human-readable shell.|
|`docker ps`|List containers.|`docker ps`|Defense: show 3 running.|
|`docker stop`|Stop container(s).|`docker stop <id>`|Free ports.|
|`docker rm`|Remove container(s).|`docker rm <id>`|Cleanup.|
|`docker exec`|Run inside container.|`docker exec -it nginx bash`|Inspect configs/logs.|
|`docker volume ls`|List volumes.|`docker volume ls`|Prove persistence.|
|`docker volume inspect`|Inspect volume.|`docker volume inspect wordpress`|Check host path.|
|`docker volume rm`|Delete volume.|`docker volume rm <vol>`|Reset DB/files.|
|`docker network ls`|List networks.|`docker network ls`|Confirm inception network.|
|`docker network inspect`|Inspect network.|`docker network inspect inception`|Prove container connectivity.|
|`docker network rm`|Delete network.|`docker network rm inception`|Reset config.|
|`docker compose up`|Start infra.|`docker compose up -d`|Main start.|
|`-d` (detached)|Background mode.|`docker compose up -d`|Terminal free.|
|`--build`|Force rebuild.|`docker compose up -d --build`|Use after config changes.|
|`docker compose ps`|List compose containers.|`docker compose ps`|Show 3 running.|
|`docker compose logs`|Show logs.|`docker compose logs -f`|Debug errors.|
|`-f` (follow)|Stream live logs.|`docker compose logs -f`|Monitor services.|
|`docker compose stop`|Stop services.|`docker compose stop`|Keep volumes.|
|`docker compose down`|Stop & remove.|`docker compose down`|Clean reset.|
|`-v` (volumes)|Also delete volumes.|`docker compose down -v`|Fresh install.|
|`docker system prune`|Delete unused.|`docker system prune -af`|Final cleanup.|
|`curl -kI`|HEAD HTTPS request.|`curl -kI https://login.42.fr`|Check TLS port 443 only.|
|`-k`|Ignore SSL errors.|`curl -k https://...`|Self-signed cert.|
|`-I`|Headers only.|`curl -I https://...`|Faster check.|
|`openssl s_client`|Manual TLS test.|`openssl s_client -connect login.42.fr:443 -tls1_2`|Prove TLS versions.|
|`-connect host:port`|Target.|`-connect login.42.fr:443`|Test DNS + port.|
|`-tls1_2` / `-tls1_3`|Force TLS version.|`-tls1_2`|Subject requires v1.2/1.3.|

---
