How to sping up the db service along with disaster recovery setup.

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
