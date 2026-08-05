# ml4gw-quickstart
Welcome to `ml4gw`! Here you will find assistance setting up your software
environment on the LIGO Data Grid (LDG) to interact with `ml4gw` applications.

This setup will prepare you to work with any of the main ML4GW projects:

| Repository | Description |
| --- | --- |
| [`ml4gw`](https://github.com/ML4GW/ml4gw) | Core library of GPU-accelerated utilities for gravitational-wave data analysis with PyTorch ([docs](https://ml4gw.github.io/ml4gw/)) |
| [`aframe`](https://github.com/ML4GW/aframe) | End-to-end pipeline for detecting compact binary mergers ([docs](https://ml4gw-aframe.readthedocs.io/)) |
| [`amplfi`](https://github.com/ML4GW/amplfi) | Likelihood-free parameter estimation of gravitational-wave events ([docs](https://amplfi.readthedocs.io/)) |
| [`hermes`](https://github.com/ML4GW/hermes) | Inference-as-a-service tooling for deploying models with Triton |

There are a lot of steps below. If anything goes wrong, please open an issue on this repo!

## Makefile
The main utility of this repository is a `Makefile` for installing software,
and setting up environment variables.

Begin by cloning, and entering this repository on your account on LDG:

> **Note** Ensure that you have added a [github ssh key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account) to your account

```console
git clone git@github.com:ML4GW/quickstart.git
cd quickstart
```

Now, you can run the steps below to configure the necessary software.
Steps 0-2 are necessary for essentially all ML4GW work, and can be run at once
with `make core`. Steps 3-4 are needed only for launching remote jobs on
Nautilus, and can be run with `make optional`. `make all` runs everything.

### 0. Add necessary LDG authentication variables to your `~/.bash_profile`
```console
make mkdirs export-vars
```

What this runs:

```make
mkdirs:
	@mkdir -p $(KERBEROS_DIR)

export-vars:
	@echo 'export KRB5_KTNAME=$(KRB5_KTNAME)' >> $(HOME)/.bash_profile
	@echo 'export LIGO_USERNAME=$(USER)' >> $(HOME)/.bash_profile
	@echo 'export LIGO_GROUP=$(LIGO_GROUP)' >> $(HOME)/.bash_profile
```

If you're new to the LIGO Data Grid, you may need to configure authentication settings.
The below environment variables configure your environment for authentication to
LDG data services. For more details, please see the [LDG computing docs](https://computing.docs.ligo.org/guide/computing-centres/ldg/)

- [`KRB5_KTNAME`](https://computing.docs.ligo.org/guide/auth/kerberos/) holds the path to the keytab for passwordless renewal of credentials.
- [`LIGO_USERNAME`](https://computing.docs.ligo.org/guide/htcondor/access/) holds your `albert.einstein` username, used for HTCondor accounting.
- [`LIGO_GROUP`](https://computing.docs.ligo.org/guide/htcondor/access/) holds the HTCondor accounting group your jobs are tagged with. The default, `ligo.dev.o4.cbc.allsky.aframe`, is appropriate for `aframe` development.

### 1. Install uv
```console
make install-uv
```

What this runs:

```make
install-uv:
	@curl -LsSf https://astral.sh/uv/install.sh | sh
```

[uv](https://docs.astral.sh/uv/) is an environment management tool similar to pip. `ml4gw` projects use uv
for dependency management, building virtual environments, and publishing packages to PyPI.
Within any project repository, `uv sync` will build the project's environment, and
`uv run <command>` will execute a command inside of it.

### 2. Download and install Miniforge
```console
make install-miniforge
source ~/.bashrc
```

What this runs:

```make
install-miniforge:
	@curl -LsSf -o Miniforge3.sh https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$$(uname)-$$(uname -m).sh
	@bash Miniforge3.sh -b
	@$(HOME)/miniforge3/bin/conda init
	@rm Miniforge3.sh
```

uv will handle most of the day-to-day management of Python environments,
but some workflow dependencies are still distributed only via conda.
For example, `aframe`'s Snakemake pipeline requires you to build its
orchestrator environment with `conda env create -f pipeline/envs/snakemake.yaml`.

This conda environment will now automatically be activated each time you login.
If you do not want this environment to be activated by default you can configure conda to not activate by default:
```console
conda config --set auto_activate_base false
```

### 3. Install Kubectl and Helm
```console
make install-kubectl install-helm
```

What this runs:

```make
install-kubectl:
	@curl -LsS -o ~/.local/bin/kubectl "https://dl.k8s.io/release/$$(curl -LsS https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
	@chmod +x ~/.local/bin/kubectl

install-helm:
	@curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
	@chmod 700 get_helm.sh
	@USE_SUDO=false HELM_INSTALL_DIR=~/.local/bin ./get_helm.sh
	@rm get_helm.sh
```

`kubectl` and `helm` are command line tools for submitting and interacting with jobs on a Kubernetes cluster. See the
section on Nautilus below for more information on why this is necessary.

### 4. Install the AWS CLI and S3cmd
```console
make install-aws install-s3cmd
```

What this runs:

```make
install-aws:
	@curl -LsS -o awscliv2.zip "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
	@unzip -q awscliv2.zip
	@./aws/install --bin-dir ~/.local/bin --install-dir $(HOME)/.aws-cli
	@rm -rf aws awscliv2.zip

install-s3cmd:
	@~/.local/bin/uv tool install s3cmd
```

The `aws` and `s3cmd` command line utilities provide tools for uploading, retrieving and managing files stored on remote S3 servers.
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
with `albert.einstein` replaced with your LIGO username. Move this keytab file to the `~/.kerberos` directory that will already be created after running the makefile

```console
mv ligo.org.keytab ~/.kerberos
```

Now you're all set! LIGO data services authenticate with [SciTokens](https://computing.docs.ligo.org/guide/auth/scitokens/). To refresh your credentials, simply run

```console
kinit albert.einstein@LIGO.ORG -k -t $KRB5_KTNAME
```

and then

```console
htgettoken -a vault.ligo.org -i igwn
```

### Weights and Biases
`ml4gw` applications like `aframe` take advantage of [Weights and Biases](https://wandb.ai/) (WandB), a platform used for tracking training experiments. To get set up with WandB, begin by making a WandB account. We can then add you to the `ml4gw` WandB team. To automate access
to WandB servers, you need to set the `WANDB_API_KEY` environment variable. Your API key can be found in your WandB [settings](https://wandb.ai/settings). It is recommended to add this to your `~/.bash_profile` alongside the other environment variables configured above.

## Nautilus and S3
Nautilus is a cluster of mostly GPU resources. `ml4gw` applications like `aframe` take advantage of Nautilus for
launching remote training jobs, and larger scale hyperparameter searches. See the [nautilus getting started docs](https://nrp.ai/documentation/userdocs/start/getting-started/) to get setup with a nautilus account, and for information on configuring the Kubernetes command line tool, `kubectl`. `kubectl` was already installed for you by running the `Makefile`. It is also recommended to read through all of their docs to get familiar with the basics of Kubernetes.

Nautilus also has S3 storage locations to allow accessing data from within jobs. Please see the [nautilus S3 docs](https://nrp.ai/documentation/userdocs/storage/ceph-s3/) for information on getting S3 credentials from the admins. Once you receive your credentials, store them in
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

Also, store them in the `AWS_SECRET_ACCESS_KEY` and `AWS_ACCESS_KEY_ID` environment variables in your `~/.bash_profile`, along with `AWS_ENDPOINT_URL=https://s3-west.nrp-nautilus.io`, which tells `ml4gw` pipelines where to find the S3 server.

