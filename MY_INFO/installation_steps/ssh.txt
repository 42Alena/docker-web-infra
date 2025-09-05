school:
find ssh
    Folders:

    ->Home
    ->show hiddden  files
    -> folder .ssh

    Terminal: ls -l ~/.ssh
        The private key is usually id_rsa (no extension).
        The public key is id_rsa.pub.
    ssh-keygen -lf ~/.ssh/id_rsa 
3072 SHA256:gRpCypQ1ZfvL/7weNHGattDGJmqF53DsaRT4ygJiFPU akurmyza@4c0c30.42berlin.de (RSA)

You can check the fingerprint of your private key to confirm it’s the same one Intra shows:
ssh-keygen -lf ~/.ssh/id_rsa

[]You must copy the key pair into your VM:

    Private key (keep secret!):
    ~/.ssh/id_rsa

    Public key (can share):
    ~/.ssh/id_rsa.pub

📂 Inside your VM
They should live here:
~/.ssh/id_rsa
~/.ssh/id_rsa.pub

And permissions must be strict:
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

If you copy the same whole ~/.ssh/ folder into your VM, then your VM will “be you”:

It can connect to Intra.

It can connect to GitHub.

And it remembers trusted hosts (known_hosts), so no extra “Are you sure you want to continue connecting?” prompts.

🚚 Copy all keys into your VM

If you want your VM to behave exactly like your host, you can simply copy the .ssh folder:

On your host (replace user@vm-ip with your VM login + IP):

scp -r ~/.ssh user@vm-ip:~/


General form
The scp command is for copying files from your host → into your VM over SSH.
scp -r ~/.ssh USERNAME@VM_IP:~/


scp → secure copy

-r → recursive (copies the whole .ssh folder and its files)

~/.ssh → source folder on your host

USERNAME@VM_IP → who & where in the VM to send the files

:~/ → put it in the VM user’s home directory

Replace with your values

USERNAME → the user you created in Debian installer (probably akurmyza, since your host files are under that name).

VM_IP → the IP address of your VM.

You can check the VM IP with:
ip a

Example

If your VM user is akurmyza and the VM IP is 192.168.56.101, then:
scp -r ~/.ssh akurmyza@192.168.56.101:~/
