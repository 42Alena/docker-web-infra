1. Install VM

https://github.com/codesshaman/inception/blob/main/00_INSTALL_SYSTEM.md
from subject" either the penultimate stable version of Alpine or Debian" = lasts bebore last stable version) not the last version

[]  DEBIAN VERSION: 13v for VM, 12v for Docker. amd64(from computer settings)

    new notes: Use Debian 12 (Bookworm)(docker works)
        https://mirror.accum.se/cdimage/archive/12.5.0/amd64/iso-cd/ 

        https://mirror.accum.se/cdimage/archive/12.5.0/amd64/iso-cd/debian-12.5.0-amd64-netinst.iso 
    
    Docker is not working with 13 debian version => i need for VM also 12 version debian
        https://meetings-archive.debian.net/cdimage/archive/12.5.0/amd64/iso-dvd/

        debian-12.5.0-amd64-DVD-1.iso 
    Download: https://meetings-archive.debian.net/cdimage/archive/12.5.0/amd64/iso-dvd/debian-12.5.0-amd64-DVD-1.iso

    old notes:
    for VM I will use latest 13.version, but for docker (penultimate=previous) Debian 12 “Bookworm"
    https://wiki.debian.org/DebianReleases
    https://www.debian.org/releases/
    latest/current stable :  Debian 13.0.0 “Trixie” → current stable release.
    penultimate(one before stable)  Debian 12 “Bookworm” → now the penultimate stable (previous stable).

    -school computer(in settings): os type 64 bit, grapic AMD => need download 64bitAMD ISO DEBIAN
        https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/ 

[] INSTALL VM
    - use programm  Oracle Virtualbox



[] SHUTDOWN vm in terminal:
    sudo poweroff

[] SSH installl in VM
    By default, a fresh Debian VM does not start an SSH server (sshd). We need to install and enable it.

     Log into your VM from VirtualBox (the normal console window)

        Run inside the VM:
        sudo apt update
        sudo apt install -y openssh-server


        Step 2. Enable and start SSH
        sudo systemctl enable ssh
        sudo systemctl start ssh

        Check status:
        systemctl status ssh
        👉 It should show active (running).

        Step 1. Check if SSH is listening inside VM

Inside your VM, run:
sudo ss -tlnp | grep ssh

You should see something like:
LISTEN 0 128 0.0.0.0:22  ...
LISTEN 0 128 [::]:22     ...

👉 That means SSH is listening on port 22.

Step 2. Test SSH from inside VM itself

Still inside VM:
ssh akurmyza@localhost



    If this works → SSH itself is fine, problem is with port forwarding.

    If this fails → we need to recheck SSH config.


[] PORT Forwarding 2222(dont use4242-blocked) to connect computer with vm
 DONT USE PORT 4242 at school! it used by42berlin and blocked

    in COMP. not VM

    add port:
        VBoxManage modifyvm "InceptionVM" --natpf1 "guestssh,tcp,,2222,,22"

    check:
    VBoxManage showvminfo "InceptionVM" | grep -i "Rule"    
    (will see: NIC 1 Rule(0):   name = guestssh, protocol = tcp, host ip = , host port = 2222, guest ip = , guest port = 22)


    Step 3. Test SSH connection

    On host:
    ssh user@127.0.0.1 -p 2222
    ssh akurmyza@127.0.0.1 -p 2222

    (Replace user with your VM login, e.g., akurmyza.)

    If it works → you’re inside VM 🎉




[] SSH add to use github and Intra
    NEW:
    in comp(host)terminal 
    copy .ssh folder from computer to VM with ssh
        scp -P 2222 -r ~/.ssh akurmyza@127.0.0.1:/home/akurmyza/

    s   cp = secure copy command


4. Test GitHub/intra connection

    Inside VM:ssh -T git@github.com

    5. Test Intra 42 connection

    Intra uses Git over SSH too. Try cloning:

    ssh -T git@vogsphere.42berlin.de
    prints:
    Hi there, akurmyza! You've successfully authenticated with the key named akurmyza 2022-10-12T16:04:46Z, but Gitea does not provide shell access.
    If this is unexpected, please log in with password and setup Gitea under another user.




    2. Copy your keys into the VM

    Use scp (secure copy) from your host → VM.

    Example (replace user with your VM username, and IP with your VM’s IP or use localhost if using port forwarding):



    OLD:
        0. Add port to connect to VM
            to get a usable IP for scp
                ✅ Option A: Use Port Forwarding (with NAT)

                Shut down VM.

                In VirtualBox Manager → Settings → Network → Adapter 1 → Advanced → Port Forwarding.

                Add a rule:

                Name: SSH
                Protocol: TCP
                Host IP: 127.0.0.1
                Host Port: 2222
                Guest IP: leave empty
                Guest Port: 22

                Now start VM again.
                From host, you can connect with:
                    ssh -p 2222 akurmyza@127.0.0.1
                    scp -P 2222 -r ~/.ssh akurmyza@127.0.0.1:~/

        1. 1️ Update package list

            Inside your VM run:
            sudo apt update
            his fetches the list of available packages. Without this, Debian doesn’t know where openssh-server is.

        2. Install SSH server
            sudo apt install openssh-server -y

        3. Start and enable SSH service
            sudo systemctl enable ssh
            sudo systemctl start ssh
        4. Check:
                sudo systemctl status ssh

        5.  From your host terminal(normal terminal, not VM!!!)
        from terminal normal, not vm;
            scp -P 2222 -r /home/akurmyza/.ssh akurmyza@127.0.0.1:~/
        test:
            ssh -T git@git.42.fr
            => Welcome to GitLab, @akurmyza!
        
        6. in VM:
            chmod 700 ~/.ssh
            chmod 600 ~/.ssh/id_rsa
            chmod 644 ~/.ssh/id_rsa.pub
            chmod 644 ~/.ssh/known_hosts


[] GITHUB  to vm
    after adding ssh to vm(previous step)
    0.install GIT in VM
        sudo apt update
        sudo apt install git -y
        git --version

      

    1. Inside your VM run:
        ssh -T git@github.com
    2. Clone your GitHub project

    3.Inside your VM, pick a place in your home folder (safe, writable, doesn’t need sudo).
        cd ~
        mkdir projects
        cd projects
        git clone git@github.com:42Alena/Inception.git INCEPTION_GITHUB

[] VIM install
    sudo apt update
    sudo apt install vim -y
    sudo vim /etc/hosts

[] Host USER
    Your VM name akurmyza@akurmyza is correct.

    Your domain is akurmyza.42.fr, and you must configure it in /etc/hosts, Nginx, and .env.
        inside your VM now:

    akurmyza@akurmyza →
        User = akurmyza (your 42 intra login)
        Hostname = akurmyza

    Domain for the project

        The subject and evaluation sheet require:
        Your WordPress site must be accessible at (@Task: DOMAIN_NAME=wil.42.fr)
        https://akurmyza.42.fr   (akurmyza is my 42 login)

        Where you configure this
        

        1. In the  file VM’s /etc/hosts f
            Add: 127.0.0.1   akurmyza.42.fr
            → This makes the domain akurmyza.42.fr resolve to your VM’s localhost.
        Check ping -c 1 akurmyza.42.fr

        ping sends test packets to a host to check if it can be reached.
        By default, ping keeps running forever until you press CTRL+C.
        📌 What -c 1 means
        -c = count
        -c 1 = send 1 ping request only, then stop.

        So:

        2.In your nginx config
            Inside your nginx.conf (or site conf), set:
            server_name akurmyza.42.fr;
        3.In your .env file (project root)
            DOMAIN_NAME=akurmyza.42.fr

[] VBoxGuestAdditions : mouse + Copy/paste between VM and computer


            Enable shared clipboard in VirtualBox
    VBoxGuestAdditions lives in:
        /usr/share/virtualbox/VBoxGuestAdditions.iso
    That’s fine — that’s where VirtualBox ships it by default. You don’t need to move it. You just have to mount and run it inside your Debian VM.

    in VM Oracle settings, where is this .iso click "Live CD/DVD" then restart VM 
    ✅ Steps inside Debian

    Make sure /mnt exists:
    sudo mkdir -p /mnt


    Inside Debian, check if /dev/sr0 appears:
    lsblk
    sr0   11:0   1  58.5M  0 rom

        Mount the ISO (already attached to /dev/sr0):
        sudo mount /dev/sr0 /mnt (it is letter 0 , not0 zerro)

        ls /mnt
        You should see:
    VBoxLinuxAdditions.run plus some other files.

    Run the installer:
    sudo /mnt/VBoxLinuxAdditions.run

    sudo reboot

    ✅ After reboot

    In VirtualBox menu (on host):

    Devices → Shared Clipboard → Bidirectional

    (Optional) Devices → Drag and Drop → Bidirectional

    Now:

    Mouse moves smoothly in/out of VM

    VM window resizes automatically

    Copy/paste between host ↔ VM works



            Shut down your VM.
            In VirtualBox Manager:
            Select your VM → Settings → General → Advanced.
            Set Shared Clipboard: Bidirectional.
            Set Drag’n’Drop: Bidirectional.



[] bigger VM window
    🖥️ Option A: Fixed screen size (always bigger)

        Shut down your VM.
        Open VirtualBox Manager.
        Select your VM → Settings → Display.
        Under Screen, increase Video Memory (set it to the max, usually 128 MB).
        Start your VM.
        In the VM window, go to the top menu → View → Virtual Screen 1 → Resize to 150% / 200% (or choose a resolution like 1920×1080).


[] MUST HAVE installed in VM
    Must-have tools
    Run this in terminal:
    ________________________
    sudo apt update && sudo apt install -y \
    vim \
    make \
    git \
    curl \
    wget \
    build-essential \
    ca-certificates \
    lsb-release \
    gnupg
    _______________
    Explanation

    vim → text editor (you’ll need it a lot).
    make → required by subject (Makefile builds everything).
    git → clone/push your project repo.
    curl / wget → download files from internet
    build-essential → compilers, libraries (needed for Guest Additions and Docker builds).
    ca-certificates / gnupg / lsb-release → required to add Docker’s official repository.


[] DOCKE, DOCKER Compose
   https://docs.docker.com/manuals/
   https://docs.docker.com/guides/

   install Docker:
   https://docs.docker.com/engine/install/debian/


   
   1.Step: Add Docker’s GPG key
   ___   from official page:____________________________________________________
        # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    ____________________________

    Explain:
    
        ca-certificates + curl → tools to download securely.
        /etc/apt/keyrings → new folder for trusted repo keys.
        Downloads Docker’s GPG key (docker.asc) → so apt can verify packages are genuine.
        chmod a+r → makes the key readable by apt.

    2.Step: Add Docker repository
        ________   from official page:________________
        # Add the repository to Apt sources:
        echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
    _______________________________
    Explain:
        Creates a new apt repo file at /etc/apt/sources.list.d/docker.list.
        $(dpkg --print-architecture) → ensures correct architecture (amd64).
        $(. /etc/os-release && echo "$VERSION_CODENAME") → auto-detects your Debian codename (for Debian 12 → bookworm).
        Then apt-get update → refresh package list with Docker repo added.

    3.Step
       
        After adding the repo, install Docker itself:
        To install the latest version, run:
        sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    4.Step:
        Verify that the installation is successful by running the hello-world image:

        sudo docker run hello-world
    This command downloads a test image and runs it in a container. When the container runs, it prints a confirmation message and exits
    You have now successfully installed and started Docker Engine.

[] install DOCKER Compose
    https://docs.docker.com/compose/
    install:
    https://docs.docker.com/compose/install/linux/#install-the-plugin-manually

        Install(official): 
        ________   from official page:________________
            DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
        mkdir -p $DOCKER_CONFIG/cli-plugins
        curl -SL https://github.com/docker/compose/releases/download/v2.39.2/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
        ________________________

        Apply executable permissions to the binary:

        chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

        or, if you chose to install Compose for all users:

        sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

        Test the installation.

        docker compose version