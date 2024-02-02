# X509 auth directories
KERBEROS := ~/.kerberos 
CERT := ~/cilogon_cert
# auth environment variables
X509_USER_PROXY := $(CERT)/CERT_KEY.pem
KRB5_KTNAME := $(KERBEROS)/ligo.org.keytab
ECP_IDP := LIGO


# miniconda installer. Change the URL for a different os, version, or python version.
MINICONDA_INSTALLER := Miniconda3-py39_4.12.0-Linux-x86_64.sh
MINICONDA_URL := https://repo.anaconda.com/miniconda/$(MINICONDA_INSTALLER)

# default miniconda install directory
MINICONDA_INSTALL_DIR := ~/miniconda3

all: mkdirs export-vars install-conda install-poetry install-kubectl

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
	@conda init
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
