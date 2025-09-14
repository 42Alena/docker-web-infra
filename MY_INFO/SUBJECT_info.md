- [Overview: Subject/Eval rules](#toc-overview)
<a id="toc-overview"></a>
> **Subject/Eval rules you’ll prove with these commands**
> - Single entry via **NGINX on 443 with TLS v1.2/v1.3**; no HTTP 80 exposure.    
> - **Volumes live on host** under `/home/<login>/data` (WordPress files + DB).    
> - **One Dockerfile per service**; **Alpine/Debian penultimate** base only; **no DockerHub ready-made** (except base OS).    
> - **No `network: host`, no `links:`/`--link`**, no infinite loops (`tail -f`, `sleep infinity`, etc.).    
> - **Use `.env`/env vars** (passwords not in Dockerfiles). 
