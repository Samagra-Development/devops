# Onboarding your Service

## Containerizing Your service

### 1. Create a docker image for your service 

Examples:
 - [Python Dockerfile](../examples/dockerfiles/python.Dockerfile)
 - [Node Dockerfile](../examples/dockerfiles/node.Dockerfile)

Ensure the following:
 - Docker image includes a [HEALTHCHECK](https://docs.docker.com/reference/dockerfile/#healthcheck) for the [docker-test.yaml](../examples/workflows/docker-test.yaml) workflow. Ensure that [health check parameters](https://docs.docker.com/reference/dockerfile/#healthcheck) are adequate for your services.
- You can set `DISABLE_HEALTHCHECK=true` in actions environment in your repository to disable Healthcheck test in the workflow

References:

 - Best practices for Dockerfile instructions: [https://docs.docker.com/develop/develop-images/instructions/](https://docs.docker.com/develop/develop-images/instructions/)
 - For examples in other languages, you can explore [docker/awesome-compose](https://github.com/docker/awesome-compose).
 - Dockerfile reference: [https://docs.docker.com/reference/dockerfile/](https://docs.docker.com/reference/dockerfile/)

 

### 2. Add a workflow to build and push docker image to ghcr.io
Example: [/examples/workflows/build-and-push.yaml](../examples/workflows/build-and-push.yaml)

> [!IMPORTANT]  
> In case you see 403 error, checkout [this](https://docs.github.com/en/packages/learn-github-packages/configuring-a-packages-access-control-and-visibility#github-actions-access-for-packages-scoped-to-organizations)


Reference:
- For further clarification and detailed instructions, you can refer to the  [GitHub documentation](https://docs.github.com/en/actions/publishing-packages/publishing-docker-images#publishing-images-to-github-packages).

### 3. Add a workflow to test your image
Example:  [/examples/workflows/docker-test.yaml](../examples/workflows/docker-test.yaml)

### 4. To Auto Deploy Service

  #### Assumptions made:
    SERVICE_REPO: Repository from which the service is deployed.
    DEVOPS_REPO: Repository where deployment is triggered.
  #### In SERVICE_REPO
  - Allow [access via fine-grained](https://docs.github.com/en/organizations/managing-programmatic-access-to-your-organization/setting-a-personal-access-token-policy-for-your-organization#restricting-access-by-fine-grained-personal-access-tokens) personal access tokens in the organization
  - [Configure actions](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/managing-github-actions-settings-for-a-repository#allowing-access-to-components-in-a-private-repository) to be triggered from another repository within the same organization
  - Generate a Fine-Grained token (Personal Access Token) permissions required - Actions(Read and Write) and Content(Read and Write)
  - Store the PAT as repository secret, set name field as `PAT` 
  - If devops repository name is not `devops` set, the Repository Secret named `DEVOPS_REPO_NAME` and value as the name of devops repository
  - If your repository name in snake_case differs from the service name, set the Repositor Secret named `SERVICE` and value as the name of service name in snake_case
  - Create a repository secret `ENABLE_AUTO_DEPLOY` and set value for auto deployment to run for all environment given here , eg:`["dev", "stage"]`
 #### In DEVOPS_REPO
  - Create a secret named `ALLOW_EXTERNAL_TRIGGER` and set value as only allowed environments here can be triggered through other repository, eg: `["dev"]`

## Adding your service

### 1. Add service to compose
Example: [demo_service](../examples/docker-compose.yaml)

Raise a PR with the following changes
- [docker-compose.yaml](../docker-compose.yaml) updated with your required services
  - Ensure each `service` has a name in `snake_case`
  - Ensure to add a restart policy to your services so that it restarts on exit
  - Refrain exposing any ports in compose file (see caddy section below)
  - Add environment variables to [sample.env](../sample.env) and format the mandatory variables as `${VAR:?error}` in the compose file. 
  - You must configure an image tag, memory, cpu limit and replicas for your service. Refer to above example for the standard format.
   

### 2. Exposing service using caddy (Optional)

- For services you want to expose to the public, add the below block for each service to the [caddy/Caddyfile](../caddy/Caddyfile). 

    ```shell
    {$DOMAIN_SCHEME}://<service-name>.{$DOMAIN_NAME} {
        reverse_proxy <service-name-in-docker-compose>:<service-port>
    }
    ```
