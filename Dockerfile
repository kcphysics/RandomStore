FROM node:latest

RUN apt update -y && apt install -y vim git unzip zip curl less groff lsb-release gnupg

# Get AWS CLI Ready
WORKDIR /opt
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/opt/awscliv2.zip"
RUN unzip awscliv2.zip && ./aws/install

# Install Go, as we need that too
RUN wget https://go.dev/dl/go1.20.4.linux-amd64.tar.gz
RUN rm -rf /usr/local/go \
    && tar -C /usr/local -xzf go1.20.4.linux-amd64.tar.gz
RUN echo "PATH=\$PATH:/usr/local/go/bin" >> /root/.bashrc \
    && cat /root/.bashrc
RUN rm -rf go1.20.4.linux-amd64.tar.gz
# Get go dev environment ready
RUN PATH=$PATH:/usr/local/go/bin go install github.com/go-delve/delve/cmd/dlv@latest 
RUN PATH=$PATH:/usr/local/go/bin go install golang.org/x/tools/gopls@latest 
RUN PATH=$PATH:/usr/local/go/bin go install honnef.co/go/tools/cmd/staticcheck@latest

# Install and prepare Terraform
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
RUN gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
RUN echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    tee /etc/apt/sources.list.d/hashicorp.list
RUN apt update -y && apt install -y terraform

RUN mkdir /RandomStore
WORKDIR /RandomStore
COPY . .
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["debug"]
