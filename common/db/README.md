#### How to sping up the db service along with disaster recovery setup.

1. Create a clone of this repository
2. Create a copy of [sample.env](./common/sample.env) file (`cp common/sample.env .env`)
3. **Update the environment variables in the .env file as required** ( refer to below required environment variables)
4. Create a copy of example docker-compose file (`cp docker-compose.yaml.example docker-compose.yaml`)
5. Edit the docker-compose.yaml and uncomment the "db" service. 
6. Create a copy of example Caddyfile (`cp Caddyfile.example Caddyfile`)
7. Run `make install-docker` to install docker
8. Exit out of VM and re-connect to the VM to reflect the latest user changes
9. Run `make setup-daemon` to configure the docker daemon
10. Run `sudo make setup-webhook` to start the webhook service (use `kill -9 $(lsof -t -i:9000)` to kill any existing service on 9000 port)
11. Run `make deploy` to deploy all the services


##### REQUIRED ENVIRONMENT VARIABLES IN .env FILE

```
DOMAIN_SCHEME=http
DOMAIN_NAME=localdev.me
ENABLE_BARMAN=
BARMAN_HOST=
ID_RSA=
ID_RSA_PUB=
POSTGRES_USER=
POSTGRES_PASSWORD=
```
```
1. ENABLE_BARMAN (required ) : To tell service if database needs to be configured with barman disaster recovery/
2. BARMAN_HOST (required if ENABLE_BARMAN is set to true ) : IP of barman host where data needs to be replicated.
3. ID_RSA (required if ENABLE_BARMAN is set to true ) : private key of postgres user which will be stored in /var/lib/postgresql/.ssh/id_rsa.
4. ID_RSA_PUB= (required if ENABLE_BARMAN is set to true ) private key of postgres user which will be stored in /var/lib/postgresql/.ssh/id_rsa_pub.
5. POSTGRES_USER= (required) : User for postgres database (e.g postgres)
6. POSTGRES_PASSWORD= (required) : Password for postgres database user 
```


###### NOTE: If ENABLE_BARMAN was set to true there are three additional efforts :
a) It requires a manual start of sshd service with below command.
> docker exec -it CONTAINER_ID /usr/sbin/sshd

b)  Key pair needs to be generated and set the required value to .env file. Refer to below example:
> ssh-keygen 

 Content of below command should go to ID_RSA
  > cat ~/.ssh/id_rsa | base64 -w 0 

Content of below command should go to ID_RSA_PUB
  > cat ~/.ssh/id_rsa.pub | base64 -w 0 


c) copy the public key of postgres user from container and add it in /var/lib/barman/.ssh/authorized_keys of barman server.
> docker exec -it CONTAINER_ID cat /var/lib/postgresql/.ssh/id_rsa.pub
