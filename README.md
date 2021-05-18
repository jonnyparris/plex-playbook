# duvplex

Home NAS / Plex media server setup.
- Server setup using ansible
- Setup docker containers for all services and isolated VPN for transmission
  - ~~Plex: media server~~ ✅
  - ~~Sonarr: series tracker~~ ✅
  - ~~Radarr: movies tracker~~ ✅
  - ~~Jackett: torrent client api~~ ✅
  - ~~Tautulli: plex usage stats~~ ✅
  - Bazarr: subtitles tracker 🚧
  - Rclone: remote/cloud file management 🚧
  - Ombi: handle media requests 🚧

## Setting up ansible

``` sh
pip install ansible
pip install passlib
```

Set up the server list to play on
file:./ansible_hosts.conf

Check inventory after setting up file
``` sh
sudo mkdir /etc/ansible
sudo ln -s ~/Repos/Notes/duvplex/ansible_hosts.conf /etc/ansible/hosts
ansible-inventory --list -y

# or specify inventory
ansible-inventory -i ansible_hosts.conf --list -y
```

## Test connection

Add public key to the server as root and then test out connection

Tries to ssh as root in this case
``` sh
ansible all -m ping -u root
# or
ansible all -m ping -u root --ask-pass
```

## Vault to store passwords

file:ansible_vault_password.txt --> vault password
file:ansible_vault.yml --> Put passwords here

``` sh
cd ~/Repos/duvplex/
ansible-vault create ansible_vault.yml
ansible-vault decrypt --vault-password-file=ansible_vault_password.txt ansible_vault.yml
ansible-vault encrypt --vault-password-file=ansible_vault_password.txt ansible_vault.yml
```

## Set VPN password in the vault

file:ansible_vault.yml --> Put passwords here

``` yml
password: server_password_we_wanna_set
OPENVPN_USERNAME: sdsdsijsldijij
OPENVPN_PASSWORD: sdopksdpjsdpsijpass
PASSWORD_7Z: password used when backing up config files
```

## Execute the playbook

``` sh
ansible-playbook setup_duvplex_playbook.yml -i ansible_hosts.conf --vault-pass-file ansible_vault_password.txt
ansible-playbook setup_duvplex_playbook.yml -i ansible_hosts.conf --vault-pass-file ansible_vault_password.txt --tags backup
```

## Bring the docker containers up manually now that server is setup

Create everything
``` sh
cd ~/plex
# likely problematic so run it alone to fix it if need be because this container also holds the VPN info
docker-compose up transmission

docker-compose up # run all the services we just set up

# run as backgroun deamon
docker-compose up -d
```

## Web config

file:/ssh:jonnyparris@192.168.0.10:/mnt/data

- Transmission      ==> http://192.168.0.10:9091
- Jackett           ==> http://192.168.0.10:9117
- Radarr            ==> http://192.168.0.10:7878
- Sonarr            ==> http://192.168.0.10:8989
- Plex(After setup) ==> http://192.168.0.10:32400/web

Plex ssh tunneling, ssh like this first then the URL below will start to work, once we login in and setup stuff the normal URL above will work
``` sh
ssh -L32400:localhost:32400 jonnyparris@192.168.0.10
```

- Plex         ==> http://localhost:32400/web

## Setup dropbox uploader to backup config

https://github.com/andreafabrizi/Dropbox-Uploader

Run
``` sh
~/plex/dropbox_uploader.sh
```

## Notes

- See more detailed write up of setup steps [here](assets/DetailedWriteUp.md)
- Change entire season audio track easily: https://www.pastatool.com/ (Make sure to turn off VPN before connecting to it)
- You can find your timezone [here](https://www.gokuldeepak.com/output-for-timedatectl-list-timezones/) to customise the `TZ` var in the [docker-compose.yml](docker-compose.yml)
