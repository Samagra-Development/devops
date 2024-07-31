### Generating Key Pair for DB

1. RUN `ssh-keygen -t rsa` to generate a key pair
2. Set value of `cat ~/.ssh/id_rsa | base64 -w 0` in DB_SSH_PRIVATE_KEY (change the location of private key in command if needed)
3. Set value of `cat ~/.ssh/id_rsa.pub | base64 -w 0` in DB_SSH_PUBLIC_KEY (change the location of private key in command if needed)

### Steps to follow after the db container is started (only if you have enabled barman)

1. Currently the ssh server doesn't start automatically, run `docker exec -it DB_CONTAINER_ID /usr/sbin/sshd` to start the ssh server inside the db container

### Steps to setup Barman 

1. Run `make setup-barman` to setup barman 

> [!NOTE]

> 1. We will require the public key generated here while we setup Barman
