# X509 auth directories
KERBEROS := ~/.kerberos
CERT := ~/cilogon_cert
# auth environment variables
X509_USER_PROXY := $(CERT)/CERT_KEY.pem
KRB5_KTNAME := $(KERBEROS)/ligo.org.keytab
ECP_IDP := LIGO


# miniconda installer. Change the URL for a different os, version, or python version.
MINICONDA_INSTALLER := Miniconda3-py39_23.11.0-2-Linux-x86_64.sh 
MINICONDA_URL := https://repo.anaconda.com/miniconda/$(MINICONDA_INSTALLER)

# default miniconda install directory
MINICONDA_INSTALL_DIR := ~/miniconda3-tmp

all: mkdirs export-vars install-conda install-aws install-helm install-poetry install-kubectl install-s3cmd

# make auth directories
mkdirs:
	@mkdir -p $(KERBEROS) $(CERT)

# add auth environment variables to .bash_profile
export-vars:
	@echo 'export KRB5_KTNAME=$(KRB5_KTNAME)' >> ~/.bash_profile
	@echo 'export X509_USER_PROXY=$(X509_USER_PROXY)' >> ~/.bash_profile
	@echo 'export LIGO_USERNAME=$(USER)' >> ~/.bash_profile

install-conda:
	@echo "Downloading Miniconda installer..."
	@wget $(MINICONDA_URL)
	@echo "Installing Miniconda..."
	@bash $(MINICONDA_INSTALLER) -b -p $(MINICONDA_INSTALL_DIR)
	@$(MINICONDA_INSTALL_DIR)/bin/conda init
	@rm $(MINICONDA_INSTALLER)
	@echo "Miniconda installed successfully!"

install-poetry:
	@echo "Installing poetry..."
	@curl -sSL https://install.python-poetry.org | POETRY_HOME=$(MINICONDA_INSTALL_DIR) python3 - --version 1.7.1
	@poetry config virtualenvs.path $(MINICONDA_INSTALL_DIR)/envs

install-kubectl:
	@echo "Installing kubectl..."
	@curl -LO 'https://dl.k8s.io/release/v1.29.1/bin/linux/amd64/kubectl'
	@chmod +x kubectl
	@mv kubectl $(MINICONDA_INSTALL_DIR)/bin

install-aws:
	@curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
	@unzip awscliv2.zip
	@./aws/install --bin-dir $(MINICONDA_INSTALL_DIR)/bin --install-dir ./aws/
	@rm -rf ./aws/
	@rm awscliv2.zip

install-s3cmd:
	@wget https://sourceforge.net/projects/s3tools/files/s3cmd/2.2.0/s3cmd-2.2.0.tar.gz
	@tar xzf s3cmd-2.2.0.tar.gz
	@cd s3cmd-2.2.0 && $(MINICONDA_INSTALL_DIR)/bin/python setup.py install
	@rm -rf s3cmd*

install-helm:
	@curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
	@chmod 700 get_helm.sh
	@USE_SUDO=false HELM_INSTALL_DIR=$(MINICONDA_INSTALL_DIR)/bin/ ./get_helm.sh
	@rm ./get_helm.sh
