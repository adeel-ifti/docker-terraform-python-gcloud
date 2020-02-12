# docker-terraform-python-gcloud
dockerfile python terraform glcloud sdk pip poetry


# Instructions

Dockerfile allows us to build image to run Terraform, Python3, Google Cloud SDK, Poetry, Jinja2, Kubectl and other python related dependencies. 

Modules:
- Terraform (default version 0.11.14)
- Google cloud SDK (version 277.0.0)
- Poetry setup using .lock & .toml file (version 1.0.0 )
- Jinja2, yamllint, jq, yq

1. Navigate to your app folder and run docker build:

```bash
docker build -t terraform-python-app:1.0 \
--build-arg CLOUD_SDK_VERSION=277.0.0 \
--build-arg TERRAFORM_VERSION=0.11.14 \
--build-arg POETRY_VERSION=1.0.0 \
--no-cache .
```

2. Assuming source code & gcloud config is in the host machine, use below command to mount volume. 
Alternatively, you could use `COPY` command in dockerfile to copy `/app` and `~/.config` directories. This will allow gcloud to retain auth.

```bash
>> docker run -it --rm -v $(pwd):/app -v ~/.config:/root/.config \
        --net=host terraform-python-app:1.0

>> poetry install

>> terraform plan
Initializing modules...
- module.xxx
  Getting source "/xxx/main"
Initializing the backend...
Successfully configured the backend "xxx"! Terraform will automatically
use this backend unless the backend configuration changes.
```
