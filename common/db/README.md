### STEP 1 Generate keypair for for postgres

A. RUN `ssh-keygen -t rsa -f /opt/id_rsa` to generate a key pair. 

B. Set value of `cat /opt/id_rsa | base64 -w 0` in DB_SSH_PRIVATE_KEY (change the location of private key in command if needed). 

C. Set value of `cat /opt/id_rsa.pub | base64 -w 0` in DB_SSH_PUBLIC_KEY (change the location of private key in command if needed).

---

### STEP 2 Follow after the db container is started (only if you have enabled barman)

A. Setup the barman and streaming_barman user which is required to setup barman later.

`docker exec -u postgres -it DB_CONTAINER_ID bash`

`createuser --superuser --replication -P barman` Remember the password it will be required to setup barman later.

`createuser --replication -P streaming_barman` Remember the password it will be required to setup barman later.

C. Get the public key which will be used to setup barman later.

`cat ~/.ssh/authorized_keys` Copy this somewhere as it will be used later in setting up key based auth with barman.

now exit from db container using `exit` command twice.

D. Copy the IP address of your machine where db container is running ( do not run this in container).

` ip addr show` copy the IP this will be used when setting up DNS entry in barman server.

---

### STEP 3 Steps to setup Barman 
A. Login to barman server and switch to root user using `sudo -i` and install required packages 

`apt-get update`

`apt-get install build-essential -y`

```exit``` 

```sudo su```

B. Add DNS entry in /etc/hosts file for machine where DB container / service is running.

`vi /etc/hosts` add `POSTGRES_IP   mydb`  replace POSTGRES_IP with the actual IP address of machine where where DB container / service is running.'mydb' would be the HOSTNAME for your db server which will be required in next step during barman setup.



C. ```cd devops```,  Run `make setup-barman` to setup barman.

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

--- 

### STEP 4 add barman's public key (Refer to STEP 3.D) to postgres db user's .ssh/authorized_keys file.
A. Connect to DB server / container.

`docker exec -u postgres -it DB_CONTAINER_ID bash`

`vi ~/.ssh/authorized_keys` PASTE the content copied from STEP 3.D. Now exit from container using `exit` command twice.


### STEP 6 : Do some modifications.
1. Go to db machine and exec into the container `docker exec -u postgres -it DB_CONTAINER_ID bash`

2. type `touch ~/.hushlogin`
3. Now go to the barman machine and `vi /etc/barman.d/mydb.conf`
4. Modify the ssh_command, like: ```ssh_command = ssh -q postgres@mydb -p 2222```

### STEP 7 :  Restart postgres container
1. Connect to machine where postgres db container/service is running and run `docker restart DB_CONTAINER_ID`.

### STEP 8 : Test the replication in barman server using barman user after waiting for 2-3 minutes.
`barman check mydb` 

