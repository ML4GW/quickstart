# ml4gw-quickstart
Welcome to `ml4gw`! Here you will find assistance setting up your software
environment on the LIGO data grid (LDG) to interact with `ml4gw` applications. 

Currently, this setup is targeted for running the [`aframe`](github.com/ml4gw/aframev2) pipeline,
but many of these tools will be applicable to other projects as well. 

## Makefile
The main utililty of this repository is a `Makefile` for installing software, 
and setting up environment variables. 

Simply running `make` at the command line will:

### 1. Download and install miniconda
A local installation of [`miniconda`](https://docs.conda.io/en/latest/miniconda.html)
can be quite useful as a container for your `ml4gw` related environments. 

The specific miniconda installation can be adjusted by changing the `MINICONDA_INSTALLER` variable in the `Makefile`.
The default version should work on LDG clusters.

Additionally, the install location can be specified via altering the `MINICONDA_INSTALL_DIR` environment variable in the `Makefile`.

### 2. Install Poetry
[Poetry](https://python-poetry.org/docs/) is an environment management tool similar to pip. `ml4gw` projects use poetry
for dependency management, building virtual environments, and publishing packages to pypi. The `Makefile` will configure
your poetry settings such that all environments you build with poetry are stored in `$MINICONDA_INSTALL_DIR/envs`.

### 3. Install Kubectl
`kubectl` is a command line tool for submitting and interacting with jobs on a Kubernetes cluster. See the 
section on Nautilus below for more information on why this is necessary. 


### 3. Add necessary LDG authentication variables to your `~/.bash_profile`
The below environment variables configure your environment for authentication to 
LDG data services. For more details, please see the LDG computing [docs](https://computing.docs.ligo.org/guide/computing-centres/ldg/)

- [`KRB5_KTNAME`](https://computing.docs.ligo.org/guide/auth/kerberos/?h=krb) holds the path to the keytab for passwordless renewal of credentials.
- [`X509_USER_PROXY`](https://computing.docs.ligo.org/guide/auth/x509/) holds path to the X509 credential for data access.
- [`ECP_IDP`](https://computing.docs.ligo.org/guide/auth/x509/?h=ecp_idp#ligo) holds the default identitiy provider for generating new credentials.

## After Running Make
Once the `Makefile` completes, there a still a few setup tasks required.

### Kerberos Keytab
A kerberos keytab allows for automaticm, passwordless generation of credentials to LIGO data services. The `ktutil` command line tool 
used to generate kerberos keytabs is already installed system wide on the LDG cluster. Generate a kerberos keytab by running:

```console
$ ktutil
ktutil:  addent -password -p albert.einstein@LIGO.ORG -k 1 -e aes256-cts-hmac-sha1-96
Password for albert.einstein@LIGO.ORG:
ktutil:  wkt ligo.org.keytab
ktutil:  quit
```
with `albert.einstein` replaced with your LIGO username. Move this keytab file to `~/.kerberos` directory that will already be created by after running the makefile

```console
mv ligo.org.keytab ~/.kerberos
```

Now your all set! To refresh your X509 credential, simply run

```console
ecp-get-cert -k
```
Where the `-k` flag tells `ecp-get-cert` to utilize your kerberos keytab for passwordless generation.

### Weights and Biases
`ml4gw` applications like `aframe` take advantage of [Weights and Biases](https://wandb.ai/) (WandB), a platform used for tracking training experiments. To get set up with WandB, begin by making a WandB account. We can then add you to the `ml4gw` WandB team. To automate access 
to WandB servers, you need to set the `WANDB_API_KEY` environment variable. Your API key can be found in your WandB [settings](https://wandb.ai/settings). It is recommended to add this to your `~/.bash_profile` alongside the other environment variables configured above. 

## Nautilus and S3
Nautilus is a cluster of mostly GPU resources. `ml4gw` applications like `aframe` take advantage of Nautilus for
launching remote training jobs, and larger scale hyperparameter searches. See the nautilus [docs](https://docs.nationalresearchplatform.org/userdocs/start/get-access/) to get setup with a nautilus account, and visit the [quickstart](https://docs.nationalresearchplatform.org/userdocs/start/quickstart/) page for information on configuring the Kubernetes command line tool, `kubectl`. `kubectl` was already installed for you by running the `Makefile`. It is also recommended to read through all of their docs to get familiar with the basics of Kubernetes.

Nautilus also has S3 storage locations to allow accessing data from within jobs. Please see the S3 [docs](https://docs.nationalresearchplatform.org/userdocs/storage/ceph-s3/) for information on getting S3 credentials from the admins. Once you recieve your credentials, store them in 
`$HOME/.aws/credentials` as 

```
[default]
aws_access_key_id = <access key>
aws_secret_access_key = <secret key>
```













