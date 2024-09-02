# ml4gw-quickstart
Welcome to `ml4gw`! Here you will find assistance setting up your software
environment on the LIGO data grid (LDG) to interact with `ml4gw` applications. 

Currently, this setup is targeted mostly for running the [`aframe`](github.com/ml4gw/aframev2) pipeline,
but many of these tools will be applicable to other projects as well. 

There are a lot of steps below. If anything goes wrong, please open an issue on this repo!

## Makefile
The main utililty of this repository is a `Makefile` for installing software, 
and setting up environment variables. 

Begin by cloning, and entering this repository on your account on LDG:

> **Note** Ensure that you have added a [github ssh key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account) to your account 

```console
git clone git@github.com:ml4gw/quickstart.git
cd quickstart
```

Now, you can run the steps below to configure the necessary software.
To just run `aframe`, only steps 0-2 are necessary. To contribute to the development of `aframe`, it may be desirable to complete all steps.

### 0. Add necessary LDG authentication variables to your `~/.bash_profile`
```console
make mkdirs export-vars
```
If you're new to the LIGO Data Grid, you may need to configure authentication settings,
The below environment variables configure your environment for authentication to 
LDG data services. For more details, please see the [LDG computing docs](https://computing.docs.ligo.org/guide/computing-centres/ldg/)

- [`KRB5_KTNAME`](https://computing.docs.ligo.org/guide/auth/kerberos/?h=krb) holds the path to the keytab for passwordless renewal of credentials.
- [`X509_USER_PROXY`](https://computing.docs.ligo.org/guide/auth/x509/) holds path to the X509 credential for data access.
- [`ECP_IDP`](https://computing.docs.ligo.org/guide/auth/x509/?h=ecp_idp#ligo) holds the default identitiy provider for generating new credentials.

### 1. Download and install miniconda
```console
make install-conda
source ~/.bashrc
```
A local installation of [`miniconda`](https://docs.conda.io/en/latest/miniconda.html)
can be quite useful as a container for your `ml4gw` related environments. 

The specific miniconda installation can be adjusted by changing the `MINICONDA_INSTALLER` variable in the `Makefile`.
The default version should work on LDG clusters.

Additionally, the install location can be specified via altering the `MINICONDA_INSTALL_DIR` environment variable in the `Makefile`.
This conda environment will now automatically be activated each time you login.

If you do not want this environment to be activated by default you can configure conda to not activate by default:
```console
conda config --set auto_activate_base false
```

### 2. Install Poetry
```console
make install-poetry
```
[Poetry](https://python-poetry.org/docs/) is an environment management tool similar to pip. `ml4gw` projects use poetry
for dependency management, building virtual environments, and publishing packages to pypi. The `Makefile` will configure
your poetry settings such that all environments you build with poetry are stored in `$MINICONDA_INSTALL_DIR/envs`.

### 3. Install Kubectl and Helm
```console
make install-kubectl install-helm
```
`kubectl` and `helm` are command line tools for submitting and interacting with jobs on a Kubernetes cluster. See the 
section on Nautilus below for more information on why this is necessary. 

### 4. Install S3cmd
```console
make install-s3cmd
```
The `s3cmd` command line utility provides tools for uploading, retreiving and managing files stored on remote S3 servers.
For example,

```console
s3cmd ls s3://{bucket}/{path}
```

will list all of the files and directories stored at the given path once you have completed the credential setup below.

## After Running Make
Once you're done installing things, there are still a few setup tasks required. 


### Kerberos Keytab
A kerberos keytab allows for password-less generation of credentials to LIGO data services. This can be extremely useful for automating data access scripts. The `ktutil` command line tool used to generate kerberos keytabs is already installed system wide on the LDG cluster. Generate a kerberos keytab by running:

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

Now you're all set! To refresh your X509 credential, simply run

```console
kinit albert.einstein
```

and then 

```console
ecp-get-cert -k
```
Where the `-k` flag tells `ecp-get-cert` to utilize your kerberos keytab for passwordless generation.

### Weights and Biases
`ml4gw` applications like `aframe` take advantage of [Weights and Biases](https://wandb.ai/) (WandB), a platform used for tracking training experiments. To get set up with WandB, begin by making a WandB account. We can then add you to the `ml4gw` WandB team. To automate access 
to WandB servers, you need to set the `WANDB_API_KEY` environment variable. Your API key can be found in your WandB [settings](https://wandb.ai/settings). It is recommended to add this to your `~/.bash_profile` alongside the other environment variables configured above. 

## Nautilus and S3
Nautilus is a cluster of mostly GPU resources. `ml4gw` applications like `aframe` take advantage of Nautilus for
launching remote training jobs, and larger scale hyperparameter searches. See the [nautilus docs](https://docs.nationalresearchplatform.org/userdocs/start/get-access/) to get setup with a nautilus account, and visit the [nautilus quickstart](https://docs.nationalresearchplatform.org/userdocs/start/quickstart/) page for information on configuring the Kubernetes command line tool, `kubectl`. `kubectl` was already installed for you by running the `Makefile`. It is also recommended to read through all of their docs to get familiar with the basics of Kubernetes.

Nautilus also has S3 storage locations to allow accessing data from within jobs. Please see the [nautilus S3 docs](https://docs.nationalresearchplatform.org/userdocs/storage/ceph-s3/) for information on getting S3 credentials from the admins. Once you recieve your credentials, store them in 
`$HOME/.aws/credentials` as 

```
[default]
aws_access_key_id = <access key>
aws_secret_access_key = <secret key>
```
As well as in `$HOME/.s3cfg`:

```
[default]
access_key = <access key>
host_base = https://s3-west.nrp-nautilus.io
host_bucket = https://s3-west.nrp-nautilus.io
secret_key = <secret key>
use_https = True
```

Also, store them in the `AWS_SECRET_ACCESS_KEY` and `AWS_ACCESS_KEY_ID` environment variables in your `~/.bash_profile`












