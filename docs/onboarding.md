# Onboarding your Service

## Containerizing Your service

### 1. Create a docker image for your service 

Examples:
 - [Python Dockerfile](../examples/dockerfiles/python.Dockerfile)
 - [Node Dockerfile](../examples/dockerfiles/node.Dockerfile)

Ensure the following:
 - Docker image includes a [HEALTHCHECK](https://docs.docker.com/reference/dockerfile/#healthcheck) for the [docker-test.yaml](./examples/workflows/docker-test.yaml) workflow. Ensure that [health check parameters](https://docs.docker.com/reference/dockerfile/#healthcheck) are adequate for your services.
- You can set `DISABLE_HEALTHCHECK=true` in actions environment in your repository to disable Healthcheck test in the workflow

References:

 - Best practices for Dockerfile instructions: [https://docs.docker.com/develop/develop-images/instructions/](https://docs.docker.com/develop/develop-images/instructions/)
 - For examples in other languages, you can explore [docker/awesome-compose](https://github.com/docker/awesome-compose).
 - Dockerfile reference: [https://docs.docker.com/reference/dockerfile/](https://docs.docker.com/reference/dockerfile/)

 

### 2. Add a workflow to build and push docker image to ghcr.io
Example: [/examples/workflows/build-and-push.yaml](../examples/workflows/build-and-push.yaml)

> [!IMPORTANT]  
> In case you see 403 error, checkout [this](https://docs.github.com/en/packages/learn-github-packages/configuring-a-packages-access-control-and-visibility#github-actions-access-for-packages-scoped-to-organizations)

### To Auto Deploy Service
- [Allow access via fine-grained personal access tokens in Organisation](https://docs.github.com/en/organizations/managing-programmatic-access-to-your-organization/setting-a-personal-access-token-policy-for-your-organization#restricting-access-by-fine-grained-personal-access-tokens)
- [Configure actions to be triggered from another repository within the same organization](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/managing-github-actions-settings-for-a-repository#allowing-access-to-components-in-a-private-repository)
- Generate a PAT (Personal Access Token) with appropriate scopes to initiate actions, [check permissions here](https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28#create-a-repository-dispatch-event)
- Store the PAT as [repository secret](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions#creating-secrets-for-a-repository) in repository setting, set name field as `PAT` 
- Change the repo name if not devops in the step:Trigger deployment workflow <br/>
  `https://api.github.com/repos/${{ github.repository_owner }}/devops/dispatches`
- Create a [Repository Variable](https://docs.github.com/en/actions/learn-github-actions/variables#creating-configuration-variables-for-a-repository), with `NAME` as `SERIVCE` and `value` as `repository_name(in snake case)` 

- Push from the `dev` branch only to auto deploy

Reference:
- For further clarification and detailed instructions, you can refer to the  [GitHub documentation](https://docs.github.com/en/actions/publishing-packages/publishing-docker-images#publishing-images-to-github-packages).

### 3. Add a workflow to test your image
Example:  [/examples/workflows/docker-test.yaml](../examples/workflows/docker-test.yaml)


## Adding your service

### 1. Add service to compose
Example: [demo_service](../examples/docker-compose.yml)

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
