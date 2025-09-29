# VM steps
## install tree for folder structure
```bash
sudo apt update
sudo apt install tree -y
```
run
```bash
tree -a -L 3
```

## 1) Create the folders on the VM (one-time)
```bash
mkdir -p /home/$USER/data/mariadb /home/$USER/data/wordpress
sudo chown -R $USER:$USER /home/$USER/data
```

## ENV: 

Repo: .env in srcs/, but with fake values/placeholders.

VM for defense: real .env in ~/inception/srcs/.env.

Git: .env must be ignored (.gitignore entry).

## Make 

A snapshot = frozen copy of your VM at one moment.
If something goes wrong later (bad config, crash, wrong .env), you can restore snapshot and VM instantly goes back to that state.

### ⚙️ How to create a snapshot (VirtualBox)

### !You do it from your host system, not inside the VM.

- Shut down your VM (better: sudo shutdown now inside Debian).

- In VirtualBox Manager, right-click your VM → Snapshots.

- Click Take… (camera icon).

- Give it a clear name, e.g. after_build_ok or pre_eval_fresh.

- Start VM again.

### 🗂️ Suggested snapshots for Inception defense

- pre_eval_clean → fresh repo, before make.

- after_build_ok → after make works, containers run.

###
Option 2 — Add your user to the docker group (best practice, required for defense)
# Add your user to docker group
sudo usermod -aG docker $USER

# Log out and back in OR:
su - $USER
