FROM python:3.6-slim-stretch

MAINTAINER James R <j@mesway.io>

# Build ARGs would be ideal for the tool versions.
# The problem is ENVs make displaying the tool versions when the container runs much easier,
# but they allow someone to artificially change the versions with an -e TERRAFORM_VERSION=...
# Not a huge deal, but it might be confusing if they think that would give them a different version of the tool.
# My preferred way is to query the tool eg. terraform --version, ansible --version... to display the tool verisons,
# but ansible --version is really slow since it gives back everything.
# I left this functionality in for comparison - start the container with no args to see it action
# ARG TERRAFORM_VERSION=0.11.7
# ARG ANSIBLE_VERSION=2.6.1
# ARG AWS_CLI_VERSION=1.15.55

ENV APP_PATH /code
ENV SRC_PATH /tmp

ENV TERRAFORM_VERSION=0.11.7
ENV ANSIBLE_VERSION=2.6.1
ENV AWS_CLI_VERSION=1.15.55
# default region
ENV AWS_DEFAULT_REGION=us-east-1

WORKDIR ${SRC_PATH}

# In life and Docker, I try to minimize the RUNs as much as possible
# if I'm setting up more than 3 services, I might break them into seprate RUNs
RUN BUILD_DEPS='unzip \
                wget' && \
    # groff is an aws dependency
    RUN_DEPS='groff \
              ntpdate' && \
    apt-get update && \
    apt-get install -yqq ${BUILD_DEPS} ${RUN_DEPS} --no-install-recommends && \
    # Terraform
    wget -q "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    wget -q "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS" && \
    grep "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" "terraform_${TERRAFORM_VERSION}_SHA256SUMS" | sha256sum -c && \
    unzip "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -d /usr/local/bin && \
    rm -rf "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    rm -rf "terraform_${TERRAFORM_VERSION}_SHA256SUMS" && \
    # pip Ansible and aws-cli
    pip install --upgrade pip && \
    pip install ansible=="${ANSIBLE_VERSION}" && \
    pip install awscli=="${AWS_CLI_VERSION}" && \
    # cleanup
    apt-get purge -y --auto-remove ${BUILD_DEPS} && \
    rm -rf /var/lib/apt/lists/*

# I keep the file cp/bash stuff on the bottom to take advantage of caching the heavier stuff above
COPY .gitignore ${SRC_PATH}
COPY .example-env ${SRC_PATH}
COPY docker-compose.yml ${SRC_PATH}
COPY example.tf ${SRC_PATH}
COPY td.sh ${SRC_PATH}
COPY entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR ${APP_PATH}

ENTRYPOINT ["/bin/bash", "/usr/local/bin/entrypoint.sh"]
