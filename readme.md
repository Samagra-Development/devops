## Developer Documentaion

1. [Usecase](./docs/usecase.md)
2. [Onboarding a service](./docs/onboarding.md) 

# Usecase
The DevOps repository provides streamlined deployment and management of services for monitoring, logging, object storage, environment management, and reverse proxy capabilities. For more detail read [Usecase](./docs/usecase.md).
# Local Setup

## Requirements for Local Setup
1. Ensure that Docker is installed on your system. You can install Docker by following the official Docker installation guide for your operating system: [Docker Installation Guide](https://docs.docker.com/engine/install/).

## Steps to Deploy

### 1. Create a Github Organisation if does'nt exist
Create an Organisation on Github, read official [Github Docs](https://docs.github.com/en/enterprise-server@3.11/organizations/collaborating-with-groups-in-organizations/creating-a-new-organization-from-scratch) to do so.

### 2. Fork the Repository
- Fork the repostory to the created organisation.

### 3. Setup the Environment Variable
- Copy the sample.env in common directory to .env in the root directory. 
- `cp common/sample.env .env`

### 4. Setup Docker-Compose file
- Copy the docker-compose.example.yaml file in the root directory to the docker-compose.yaml.
- `cp docker-compose.example.yaml docker-compose.yaml` 

### 5. Setup Caddyfile
- Copy Caddyfile.example to Caddyfile in the root directory.
- `cp Caddyfile.example  Caddyfile`

### 6. Run Make commmand
- RUN `make deploy`
- For other make commands check bellow.

## Useful Commands 

1. Deploy a newly added service or pull and redeploy a service

    `make deploy [services=<service_name>]`

3. Stop a service 

    `make stop [services=<service_name>]`

4. Restart a service 

    `make restart [services=<service_name>]`

5. Delete a service 

    `make down [services=<service_name>]`
    
    Note: Volumes are preserved
    
6. Pull images
    `make pull [services=<service_name>]`

7. Build images
    `make build [services=<service_name>]`

> [!NOTE]
>  Optional environment variable to tweak behaviour of Makefile:
> 1. `ENABLE_FORCE_RECREATE` (set this to 1 to enable force recreations of containers every time a service is deployed)
> 2. `DISABLE_ANSI` (set this to 1 to prevent ANSI output from Docker CLI)
> 3. `DISABLE_REMOVE_ORPHANS` (orphan containers are removed by default when your run `make deploy` without <service_name>, set this to 1 to disable this behaviour)
> 4. `DISABLE_PULL` (images are pulled/rebuilt by default (if you provide `<service_name>`, image for only that service is pulled/rebuilt) when you run `make deploy [services=<service_name>]`,  set this to 1 to disable this behaviour)
> 5. `<service_name>` accepts either one or multiple values separated by space
