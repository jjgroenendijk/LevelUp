# GitHub Self-Hosted Runner Setup# GitHub Self-Hosted Runner Setup# GitHub Self-Hosted Runner Setup

Self-hosted runner configuration for automated homelab deployments with security hardening for public repositories.Self-hosted runner configuration for automated homelab deployments with security hardening for public repositories.Documentation for configuring the GitHub Actions self-hosted runner for automated homelab deployments.

## Configuration## Architecture## Overview

- **Location**: `/opt/github-runner/`- **Location**: `/opt/github-runner/`The self-hosted runner enables automated deployment of configuration changes from the git repository to the live homelab environment. The runner executes on the same host machine and has the necessary permissions to deploy system configurations and restart services.

- **User**: `ghrunner`

- **Repository**: jjgroenendijk/LevelUp (public)- **User**: `ghrunner` (dedicated service account)

- **Version**: 2.329.0 (auto-updates)

- **Service**: actions.runner.jjgroenendijk-LevelUp.homelab-runner.service- **Repository**: jjgroenendijk/LevelUp (public)## Architecture

## Security for Public Repository- **Triggers**: Push to `main` branch only

Self-hosted runners on public repositories are risky because any user can fork and submit malicious PRs. Security controls implemented:- **Runner Version**: 2.329.0 (auto-updates)- **Runner Location**: `/opt/github-runner/`

**Workflow Restrictions**:- **Runner User**: `ghrunner` (dedicated service account)

- Deployment only runs on push to `main` (never on PRs or forks)

- PR validation uses GitHub-hosted runners (ubuntu-latest)## Security Model for Public Repository- **Permissions**: Passwordless sudo for specific deployment scripts

- CODEOWNERS requires owner approval for workflow changes

- **Repository**: Connected to the LevelUp repository

**Branch Protection** (`main` branch):

- Require PR with 1 approvalSelf-hosted runners on public repositories are dangerous because any user can fork and submit malicious PRs. Security controls:- **Triggers**: Executes workflows on push to `main` branch

- Require passing status checks

- No direct pushes**Workflow Restrictions**:## Prerequisites

- Require conversation resolution

- Deployment workflow only runs on push to `main`, never on PRs

**Runner Isolation**:

- Limited sudo (only specific scripts and commands)- PR validation uses GitHub-hosted runners (ubuntu-latest)- Arch Linux host system

- No sensitive data on runner machine

- Same network as services (no external access)- Workflow conditions prevent execution from forked repositories- Root access for initial setup

**Repository Settings** (Actions > General):- CODEOWNERS requires approval for workflow changes- GitHub repository admin access

- Require approval for first-time contributors: Enabled

- Require approval for all outside collaborators: Enabled- Docker installed and running

## Installation**Branch Protection**

### Remove Old Runner (if exists at /srv/github-runner)- Require PR with 1 approval before merging to `main`## Installation Steps

```bash- Require status checks (PR validation)

sudo systemctl stop actions.runner.*

cd /srv/github-runner- No direct pushes to `main`### 1. Create Runner User

sudo -u ghrunner ./config.sh remove --token REMOVAL_TOKEN

sudo rm -rf /srv/github-runner- Require conversation resolution

```

```bash

### Install New Runner

**Runner Isolation**:sudo useradd -r -m -d /opt/github-runner -s /bin/bash ghrunner

Get registration token: https://github.com/jjgroenendijk/LevelUp/settings/actions/runners/new

- Limited sudo permissions (only specific scripts)sudo passwd -l ghrunner  # Lock password for security

```bash

# Create user (if not exists)- No sensitive data on runner machine```

sudo useradd -r -m -d /opt/github-runner -s /bin/bash ghrunner

sudo passwd -l ghrunner- Runs in same network as services (no external access needed)



# Download and extract- Regular security updates### 2. Download GitHub Runner

sudo -u ghrunner mkdir -p /opt/github-runner

cd /opt/github-runner

sudo -u ghrunner curl -o actions-runner-linux-x64-2.329.0.tar.gz -L \

  https://github.com/actions/runner/releases/download/v2.329.0/actions-runner-linux-x64-2.329.0.tar.gz**Fork PR Configuration** (Repository Settings > Actions):Visit the repository settings to get the runner token and download URL.

sudo -u ghrunner tar xzf actions-runner-linux-x64-2.329.0.tar.gz

- Require approval for first-time contributors: Enabled

# Configure

sudo -u ghrunner ./config.sh \- Require approval for all outside collaborators: Enabled```bash

  --url https://github.com/jjgroenendijk/LevelUp \

  --token YOUR_TOKEN \sudo su - ghrunner

  --name homelab-runner \

  --labels self-hosted,Linux,X64,homelab \## Installationmkdir actions-runner && cd actions-runner

  --work _work \

  --unattendedcurl -o actions-runner-linux-x64-VERSION.tar.gz -L https://github.com/actions/runner/releases/download/vVERSION/actions-runner-linux-x64-VERSION.tar.gz



# Install service### Cleanup Existing Runnertar xzf ./actions-runner-linux-x64-VERSION.tar.gz

sudo ./svc.sh install ghrunner

sudo ./svc.sh start```

```

If old runner exists at `/srv/github-runner/`:

### Configure Sudo Permissions

Replace `VERSION` with the latest release version from GitHub.

```bash

sudo tee /etc/sudoers.d/ghrunner > /dev/null <<'EOF'```bash

ghrunner ALL=(ALL) NOPASSWD: /opt/levelup-source/scripts/deploy.sh

ghrunner ALL=(ALL) NOPASSWD: /usr/bin/docker# Stop and remove old runner### 3. Configure Runner

ghrunner ALL=(ALL) NOPASSWD: /usr/bin/rsync

ghrunner ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart *sudo systemctl stop actions.runner.*

ghrunner ALL=(ALL) NOPASSWD: /usr/bin/systemctl start *

ghrunner ALL=(ALL) NOPASSWD: /usr/bin/systemctl stop *cd /srv/github-runner```bash

EOF

sudo -u ghrunner ./config.sh remove --token REMOVAL_TOKEN./config.sh --url https://github.com/OWNER/REPO --token YOUR_TOKEN

sudo chmod 0440 /etc/sudoers.d/ghrunner

sudo visudo -csudo ./svc.sh uninstall```

```

sudo rm -rf /srv/github-runner

### Verify

```Configuration options:

```bash

# Check service- Runner name: `homelab-runner` (or descriptive name)

sudo systemctl status actions.runner.jjgroenendijk-LevelUp.homelab-runner.service

Get removal token from old repository settings if needed.- Runner group: `Default`

# Check logs

sudo journalctl -u actions.runner.* -n 50- Labels: `self-hosted,Linux,X64`



# Verify in GitHub: https://github.com/jjgroenendijk/LevelUp/settings/actions/runners### Install New Runner- Work folder: `_work` (default)

# Should show "homelab-runner" with status "Idle"

```

## Workflow ConfigurationGet registration token from: <https://github.com/jjgroenendijk/LevelUp/settings/actions/runners/new###> 4. Configure Passwordless Sudo

`.github/workflows/homelab-sync.yml`:

- Runs on: self-hosted

- Trigger: push to main only```bashCreate sudoers configuration for deployment script:

- Condition: `github.ref == 'refs/heads/main'`

- No environment approval (direct deployment)# Create user if not exists

`.github/workflows/pr-validation.yml`:sudo useradd -r -m -d /opt/github-runner -s /bin/bash ghrunner```bash

- Runs on: ubuntu-latest (GitHub-hosted, never self-hosted)

- Trigger: pull_requestsudo passwd -l ghrunnersudo visudo -f /etc/sudoers.d/ghrunner

- Validates shell scripts

- Safe for any contributor```

## Maintenance# Download and extract runner (version 2.329.0)

Monitor: `sudo journalctl -u actions.runner.* -f`sudo -u ghrunner mkdir -p /opt/github-runnerAdd the following content:

Update (auto-updates enabled, manual rarely needed):cd /opt/github-runner

```bash

sudo systemctl stop actions.runner.*sudo -u ghrunner curl -o actions-runner-linux-x64-2.329.0.tar.gz -L \```

cd /opt/github-runner

sudo -u ghrunner ./config.sh remove --token TOKEN  <https://github.com/actions/runner/releases/download/v2.329.0/actions-runner-linux-x64-2.329.0.tar.gz#> GitHub Actions runner - deployment permissions

# Download new version and extract

sudo -u ghrunner ./config.sh --url https://github.com/jjgroenendijk/LevelUp --token TOKENsudo -u ghrunner tar xzf actions-runner-linux-x64-2.329.0.tar.gzghrunner ALL=(ALL) NOPASSWD: /opt/levelup-source/scripts/deploy.sh

sudo systemctl start actions.runner.*

```ghrunner ALL=(ALL) NOPASSWD: /usr/bin/docker



## Troubleshooting# Configure runnerghrunner ALL=(ALL) NOPASSWD: /usr/bin/rsync



**Runner not appearing**: `sudo journalctl -u actions.runner.* -n 100`sudo -u ghrunner ./config.sh \```



**Permission denied**: Verify `/etc/sudoers.d/ghrunner` and test `sudo -u ghrunner sudo /opt/levelup-source/scripts/deploy.sh`  --url <https://github.com/jjgroenendijk/LevelUp> \



**Workflow not running**: Check workflow conditions, branch protection, and that PR is merged to main  --token YOUR_REGISTRATION_TOKEN \Set proper permissions:



## Risk Acceptance  --name homelab-runner \



Running self-hosted runner on public repo carries inherent risks. Mitigations:  --labels self-hosted,Linux,X64,homelab \```bash

- Workflow restrictions prevent fork PR execution

- Manual approval required for merges to main  --work _work \sudo chmod 0440 /etc/sudoers.d/ghrunner

- Limited sudo permissions

- No secrets in repository  --unattended```

- Regular monitoring

# Install as systemd service### 5. Install Runner as Systemd Service

Alternative: Make repository private (safer but limits community engagement).

sudo ./svc.sh install ghrunner

sudo ./svc.sh start```bash

```sudo ./svc.sh install ghrunner

sudo ./svc.sh start

### Configure Sudo Permissions```



```bashVerify the service is running:

sudo tee /etc/sudoers.d/ghrunner > /dev/null <<'EOF'

# GitHub Actions runner deployment permissions```bash

ghrunner ALL=(ALL) NOPASSWD: /opt/levelup-source/scripts/deploy.shsudo systemctl status actions.runner.*

ghrunner ALL=(ALL) NOPASSWD: /usr/bin/docker```

ghrunner ALL=(ALL) NOPASSWD: /usr/bin/rsync

ghrunner ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart *### 6. Configure Git Access

ghrunner ALL=(ALL) NOPASSWD: /usr/bin/systemctl start *

ghrunner ALL=(ALL) NOPASSWD: /usr/bin/systemctl stop *The runner needs access to the repository:

EOF

```bash

sudo chmod 0440 /etc/sudoers.d/ghrunnersudo su - ghrunner

sudo visudo -cssh-keygen -t ed25519 -C "github-runner@homelab"

```cat ~/.ssh/id_ed25519.pub

```

### Verify Installation

Add the public key as a deploy key in the repository settings (read-only access is sufficient).

```bash

# Check service status## Security Considerations

sudo systemctl status actions.runner.jjgroenendijk-LevelUp.homelab-runner.service

### Principle of Least Privilege

# View logs

sudo journalctl -u actions.runner.* -n 50- Runner user has minimal sudo permissions

- Only specific scripts can be executed with elevated privileges

# Check in GitHub- Runner cannot modify arbitrary system files

# Runner should appear: https://github.com/jjgroenendijk/LevelUp/settings/actions/runners- SSH keys are read-only for repository access

```

### Network Isolation

## Workflow Configuration

- Runner executes on the same host as services (no remote access required)

**Deployment Workflow** (`.github/workflows/homelab-sync.yml`):- No inbound network connections to runner

- Runs on: self-hosted- All communication initiated by runner to GitHub

- Trigger: push to main

- Condition: `github.ref == 'refs/heads/main'`### Secret Management

- Permissions: contents: read

- Never store secrets in repository

**PR Validation** (`.github/workflows/pr-validation.yml`):- Use GitHub Secrets for sensitive variables

- Runs on: ubuntu-latest (GitHub-hosted)- Environment variables passed securely to workflows

- Trigger: pull_request

- Safe for any contributor## Maintenance

- No secrets or infrastructure access

### Updating the Runner

## Maintenance

```bash

**Monitor Runner**:sudo systemctl stop actions.runner.*

```bashsudo su - ghrunner

sudo systemctl status actions.runner.*cd actions-runner

sudo journalctl -u actions.runner.* -f./config.sh remove --token YOUR_TOKEN

```# Download and extract new version

./config.sh --url https://github.com/OWNER/REPO --token YOUR_TOKEN

**Update Runner** (usually auto-updates):exit

```bashsudo systemctl start actions.runner.*

sudo systemctl stop actions.runner.*```

cd /opt/github-runner

sudo -u ghrunner ./config.sh remove --token TOKEN### Monitoring

# Download new version

sudo -u ghrunner ./config.sh --url https://github.com/jjgroenendijk/LevelUp --token TOKENCheck runner status:

sudo systemctl start actions.runner.*

``````bash

sudo systemctl status actions.runner.*

**Test Deployment**:sudo journalctl -u actions.runner.* -f

```bash```

# Manual trigger: https://github.com/jjgroenendijk/LevelUp/actions/workflows/homelab-sync.yml

# Or push change to main branchView workflow logs in GitHub Actions interface.

```

### Troubleshooting

## Troubleshooting

#### Runner Not Appearing in GitHub

**Runner not appearing**: Check `sudo journalctl -u actions.runner.* -n 100`

- Check service status: `sudo systemctl status actions.runner.*`

**Permission denied**: Verify `/etc/sudoers.d/ghrunner` and test with `sudo -u ghrunner sudo /opt/levelup-source/scripts/deploy.sh`- Verify network connectivity: `curl -I https://github.com`

- Check runner logs: `sudo journalctl -u actions.runner.* -n 50`

**Workflow not running**: Verify workflow conditions, branch protection, and PR is merged to main

#### Permission Denied Errors

**Security concern**: Any workflow changes require CODEOWNERS approval, branch protection prevents unauthorized merges

- Verify sudoers configuration: `sudo visudo -c`

## Risk Acceptance- Test sudo access: `sudo -u ghrunner sudo /opt/levelup-source/scripts/deploy.sh`

- Check file permissions on deployment script

Running self-hosted runner on public repository carries inherent risks even with controls. Mitigations in place:

- Workflow restrictions prevent fork PR execution#### Deployment Failures

- Manual approval required for merges to main

- Limited sudo permissions on runner- Verify source repository is up to date

- No secrets stored in repository- Check deployment script logs

- Regular monitoring and auditing- Ensure target directories exist and are writable

- Verify Docker socket permissions

Alternative: Make repository private (eliminates fork attack vector but limits community engagement).

## Uninstall

To remove the runner:

```bash
sudo systemctl stop actions.runner.*
sudo ./svc.sh uninstall
sudo userdel -r ghrunner
sudo rm /etc/sudoers.d/ghrunner
```

## References

- [GitHub Actions Self-Hosted Runners](https://docs.github.com/en/actions/hosting-your-own-runners)
- [Hardening Self-Hosted Runners](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)
