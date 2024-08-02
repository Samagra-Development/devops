### STEP 1 Generate keypair for for postgres

A. RUN `ssh-keygen -t rsa -f /opt/id_rsa` to generate a key pair. 

B. Set value of `cat /opt/id_rsa | base64 -w 0` in DB_SSH_PRIVATE_KEY (change the location of private key in command if needed). 

C. Set value of `cat /opt/id_rsa.pub | base64 -w 0` in DB_SSH_PUBLIC_KEY (change the location of private key in command if needed).

### STEP 2 Follow after the db container is started (only if you have enabled barman)

A. Currently the ssh server doesn't start automatically, run `docker exec -it DB_CONTAINER_ID /usr/sbin/sshd` to start the ssh server inside the db container.

B. Setup the barman and streaming_barman user which is required to setup barman later.

`docker exec -it DB_CONTAINER_ID bash`

`su - postgres`

`createuser --superuser --replication -P barman` Remember the password it will be required to setup barman later.

`createuser --replication -P streaming_barman` Remember the password it will be required to setup barman later.

C. Get the public key which will be used to setup barman later.

`cat ~/.ssh/id_rsa.pub` Copy this somewhere as it will be used later in setting up key baed auth with barman.

now exit from db container using `exit` command twice.



### STEP 3 Steps to setup Barman 
A. Login to barman server and switch to root user using `sudo -i`

B. Add DNS entry in /etc/hosts file for postgres db server / container.

`vi /etc/hosts` add `POSTGRES_IP   mydb`  replace POSTGRES_IP with the actual IP address of DB server / container and 'mydb' would be the HOSTNAME for your db server which will be required in next step during barman setup.

C. Run `make setup-barman` to setup barman.

```
- HOSTNAME/DOMAIN name of your server (e.g mydb.example.com , mydb) which we set in STEP 3.B
- Database name for which backup needs to be created.
- Password of user 'barman' which was created while configuring postgres database users in STEP 2.B
- Password of user 'streaming_barman' which was created while configuring postgres database users in STEP 2.B
```

D. Switch to barman user to generate keypair for barman.  

`su - barman`

`ssh-keygen -t rsa` It will generate keypair in home directory of barman user.

`cat ~/.ssh/id_rsa.pub` COPY this key it will be added in postgres user's .ssh/authorized_keys

E. Add public key of postgres in barman user's .ssh/authorized_keys

`vi ~/.ssh/authorized_keys` Paste the key which we copied in STEP 2.C

### STEP 4 add barman's public key (Refer to STEP 3.D) to postgres db user's .ssh/authorized_keys file.
A. Connect to DB server / container.

`docker exec -it DB_CONTAINER_ID bash`

`su - postgres`

`vi ~/.ssh/authorized_keys` PASTE the content copied from STEP 3.D. Now exit from container using `exit` command twice.

### STEP 5  Test the replication in barman server using barman user after waiting for 2-3 minutes.
`barman check mydb` 

