# X509 auth directories
KERBEROS := ~/.kerberos 
CERT := ~/cilogon_cert

# auth environment variables
X509_USER_PROXY := $(CERT)/CERT_KEY.pem
KRB5_KTNAME := $(KERBEROS)/ligo.org.keytab

# base conda environment for ml4gw development
CONDA_ENV_NAME := ml4gw
CONDA_ENV_FILE := environment.yaml

# miniconda installer. Change the URL for a different os, version, or python version.
MINICONDA_INSTALLER := Miniconda3-py39_4.12.0-Linux-x86_64.sh
MINICONDA_URL := https://repo.anaconda.com/miniconda/$(MINICONDA_INSTALLER)

# default miniconda install directory
MINICONDA_INSTALL_DIR := ~/miniconda3-test

all: create-dirs export-vars install-conda create-conda-env 

# make auth directories
create-dirs:
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
	@rm $(MINICONDA_INSTALLER)
	@echo "Miniconda installed successfully!"

create-conda-env:
	@conda env create -f $(CONDA_ENV_FILE)

