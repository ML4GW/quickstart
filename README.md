# ml4gw-quickstart
Makefile for configuring environment to develop `ml4gw` applications on LDG. 

Simply running `make` at the command line will:

## 1. Download and install miniconda

The specific miniconda installation can be adjusted by changing the `MINICONDA_INSTALLER` variable in the `Makefile`.
The default version is 
```make
MINICONDA_INSTALLER := Miniconda3-py39_4.12.0-Linux-x86_64.sh
```

Additionally, the install location can be specified via
```make
MINICONDA_INSTALL_DIR := ~/miniconda3
```

## 2. Install a `ml4gw` conda environment
that contains:
- [`poetry`](https://python-poetry.org/), which is used for package management of ml4gw applications like [`aframe`](github.com/ml4gw/aframe/) and [`PE`](github.com/ml4gw/PE).
- `krb5`, `ciecplib`, and `requests-gssapi` for renewing authentication credentials.

## 3. Add necessary LDG authentication variables to your `~/.bash_profile`
- [`KRB5_KTNAME`](https://computing.docs.ligo.org/guide/auth/kerberos/?h=krb) holds the path to the keytab for passwordless renewal of credentials.
- [`X509_USER_PROXY`](https://computing.docs.ligo.org/guide/auth/x509/) holds path to the X509 credential for data access.
- [`ECP_IDP`](https://computing.docs.ligo.org/guide/auth/x509/?h=ecp_idp#ligo) holds the default identitiy provider for generating new credentials.








