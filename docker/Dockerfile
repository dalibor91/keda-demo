FROM mcr.microsoft.com/azure-cli:latest 

# Install terraform
RUN cd /tmp && \
    wget https://releases.hashicorp.com/terraform/1.4.6/terraform_1.4.6_linux_amd64.zip && \
    unzip terraform_1.4.6_linux_amd64.zip && \
    mv terraform /bin/terraform && chmod +x /bin/terraform && rm terraform_1.4.6_linux_amd64.zip

# Install kubectl 
# latest stable version -> https://storage.googleapis.com/kubernetes-release/release/stable.txt
# RUN cd /tmp && \
#     wget https://storage.googleapis.com/kubernetes-release/release/v1.27.2/bin/linux/amd64/kubectl && \
#     mv kubectl /bin/kubectl && chmod +x /bin/kubectl 

RUN az aks install-cli

# No need for this but was too lazy to set up alias
# RUN ln -s /bin/kubectl /bin/k

ENTRYPOINT [ "/bin/bash" ]