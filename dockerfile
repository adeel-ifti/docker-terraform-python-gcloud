# https://github.com/machine-learning-helpers/docker-python-alpine/tree/master/docker/python-3.8-alpine-3.11/Dockerfile

# See also
# * Python 3.8.1 Alpine 3.11
# * Image on Docker Hub/Cloud: 
# * Dockerfile: https://github.com/docker-library/python/blob/d2a2b4f7422aac78c7d5ea6aadc49d009d184a5f/3.8/alpine3.11/Dockerfile
# * Python 3.7.6 Alpine 3.11
# * Image on Docker Hub/Cloud: https://hub.docker.com/layers/python/library/python/3.7.6-alpine3.11/images/sha256-303563b7b71e945c3a27f49d8cd9b58183b667437ab875639042ab253cf7af56
# * Dockerfile: https://github.com/docker-library/python/blob/d2a2b4f7422aac78c7d5ea6aadc49d009d184a5f/3.7/alpine3.11/Dockerfile

FROM python:3.8-buster

# Avoid warnings by switching to noninteractive
ENV POETRY_VERSION=1.0.0 \
    CLOUD_SDK_VERSION=277.0.0 \
    TERRAFORM_VERSION=0.11.14 \
    PYTHONFAULTHANDLER=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONHASHSEED=random \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    DEBIAN_FRONTEND=noninteractive

# gcloud sdk 
ENV PATH /google-cloud-sdk/bin:$PATH
RUN curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    tar xzf google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    rm google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    ln -s /lib /lib64 && \
    gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check false && \
    gcloud components install kubectl 

# install terraform
RUN wget --quiet https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && mv terraform /usr/bin \
  # Clean up
  && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /var/cache/apk/* \
  && rm -rf /var/tmp/*

# install packages
RUN  python3 -m pip install --upgrade pip \
     jinja2 --upgrade \
     yq --upgrade \
     pre-commit --upgrade \
     direnv --upgrade \
     yamllint --upgrade

# setting up poetry packages
WORKDIR /setup/
COPY poetry.lock* pyproject.toml ./
ENV PATH="/poetry/bin:${PATH}"

RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils 2>&1 \
    && apt-get -y install git jq procps lsb-release \
    # install poetry
    && pip install "poetry==$POETRY_VERSION" \
    # && poetry config settings.virtualenvs.create false \
    && if [ -f "pyproject.toml" ]; then poetry install --no-interaction --no-ansi; fi \
    && rm -rf /setup \
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

VOLUME ["/your-app", ["/root/.config"]
WORKDIR /your-app

ENTRYPOINT ["/bin/bash"]
