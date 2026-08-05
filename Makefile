# Kerberos keytab location, used for passwordless generation of SciTokens
KERBEROS_DIR := $(HOME)/.kerberos
KRB5_KTNAME := $(KERBEROS_DIR)/ligo.org.keytab

# HTCondor accounting group, used e.g. by aframe's LDG execution profile
LIGO_GROUP := ligo.dev.o4.cbc.allsky.aframe

all: core optional

# needed for essentially all ML4GW work
core: mkdirs export-vars install-uv install-miniforge

# only needed for remote work on Nautilus
optional: install-kubectl install-helm install-aws install-s3cmd

# make a directory for authentication credentials
mkdirs:
	@mkdir -p $(KERBEROS_DIR)

# add authentication environment variables to .bash_profile
export-vars:
	@echo 'export KRB5_KTNAME=$(KRB5_KTNAME)' >> $(HOME)/.bash_profile
	@echo 'export LIGO_USERNAME=$(USER)' >> $(HOME)/.bash_profile
	@echo 'export LIGO_GROUP=$(LIGO_GROUP)' >> $(HOME)/.bash_profile

# uv manages dependencies and environments for all ML4GW repositories.
install-uv:
	@curl -LsSf https://astral.sh/uv/install.sh | sh

# Miniforge provides conda for the odd dependencies that need it
install-miniforge:
	@curl -LsSf -o Miniforge3.sh https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$$(uname)-$$(uname -m).sh
	@bash Miniforge3.sh -b
	@$(HOME)/miniforge3/bin/conda init
	@rm Miniforge3.sh

# kubectl submits and manages jobs on Kubernetes clusters like Nautilus
install-kubectl:
	@curl -LsS -o ~/.local/bin/kubectl "https://dl.k8s.io/release/$$(curl -LsS https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
	@chmod +x ~/.local/bin/kubectl

# helm installs packaged applications on Kubernetes clusters
install-helm:
	@curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
	@chmod 700 get_helm.sh
	@USE_SUDO=false HELM_INSTALL_DIR=~/.local/bin ./get_helm.sh
	@rm get_helm.sh

# the AWS command line interface manages files on remote S3 storage
install-aws:
	@curl -LsS -o awscliv2.zip "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
	@unzip -q awscliv2.zip
	@./aws/install --bin-dir ~/.local/bin --install-dir $(HOME)/.aws-cli
	@rm -rf aws awscliv2.zip

# s3cmd is an alternative S3 client used by amplfi's remote training
install-s3cmd:
	@~/.local/bin/uv tool install s3cmd
