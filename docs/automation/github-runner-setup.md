# GitHub Self-Hosted Runner Setup

Documentation for configuring the GitHub Actions self-hosted runner for automated homelab deployments.

## Overview

The self-hosted runner enables automated deployment of configuration changes from the git repository to the live homelab environment. The runner executes on the same host machine and has the necessary permissions to deploy system configurations and restart services.

## Architecture

- **Runner Location**: `/opt/github-runner/`
- **Runner User**: `ghrunner` (dedicated service account)
- **Permissions**: Passwordless sudo for specific deployment scripts
- **Repository**: Connected to the LevelUp repository
- **Triggers**: Executes workflows on push to `main` branch

## Prerequisites

- Arch Linux host system
- Root access for initial setup
- GitHub repository admin access
- Docker installed and running

## Installation Steps

### 1. Create Runner User

```bash
sudo useradd -r -m -d /opt/github-runner -s /bin/bash ghrunner
sudo passwd -l ghrunner  # Lock password for security
```

### 2. Download GitHub Runner

Visit the repository settings to get the runner token and download URL.

```bash
sudo su - ghrunner
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-x64-VERSION.tar.gz -L https://github.com/actions/runner/releases/download/vVERSION/actions-runner-linux-x64-VERSION.tar.gz
tar xzf ./actions-runner-linux-x64-VERSION.tar.gz
```

Replace `VERSION` with the latest release version from GitHub.

### 3. Configure Runner

```bash
./config.sh --url https://github.com/OWNER/REPO --token YOUR_TOKEN
```

Configuration options:
- Runner name: `homelab-runner` (or descriptive name)
- Runner group: `Default`
- Labels: `self-hosted,Linux,X64`
- Work folder: `_work` (default)

### 4. Configure Passwordless Sudo

Create sudoers configuration for deployment script:

```bash
sudo visudo -f /etc/sudoers.d/ghrunner
```

Add the following content:

```
# GitHub Actions runner - deployment permissions
ghrunner ALL=(ALL) NOPASSWD: /opt/levelup-source/scripts/deploy.sh
ghrunner ALL=(ALL) NOPASSWD: /usr/bin/docker
ghrunner ALL=(ALL) NOPASSWD: /usr/bin/rsync
```

Set proper permissions:

```bash
sudo chmod 0440 /etc/sudoers.d/ghrunner
```

### 5. Install Runner as Systemd Service

```bash
sudo ./svc.sh install ghrunner
sudo ./svc.sh start
```

Verify the service is running:

```bash
sudo systemctl status actions.runner.*
```

### 6. Configure Git Access

The runner needs access to the repository:

```bash
sudo su - ghrunner
ssh-keygen -t ed25519 -C "github-runner@homelab"
cat ~/.ssh/id_ed25519.pub
```

Add the public key as a deploy key in the repository settings (read-only access is sufficient).

## Security Considerations

### Principle of Least Privilege

- Runner user has minimal sudo permissions
- Only specific scripts can be executed with elevated privileges
- Runner cannot modify arbitrary system files
- SSH keys are read-only for repository access

### Network Isolation

- Runner executes on the same host as services (no remote access required)
- No inbound network connections to runner
- All communication initiated by runner to GitHub

### Secret Management

- Never store secrets in repository
- Use GitHub Secrets for sensitive variables
- Environment variables passed securely to workflows

## Maintenance

### Updating the Runner

```bash
sudo systemctl stop actions.runner.*
sudo su - ghrunner
cd actions-runner
./config.sh remove --token YOUR_TOKEN
# Download and extract new version
./config.sh --url https://github.com/OWNER/REPO --token YOUR_TOKEN
exit
sudo systemctl start actions.runner.*
```

### Monitoring

Check runner status:

```bash
sudo systemctl status actions.runner.*
sudo journalctl -u actions.runner.* -f
```

View workflow logs in GitHub Actions interface.

### Troubleshooting

#### Runner Not Appearing in GitHub

- Check service status: `sudo systemctl status actions.runner.*`
- Verify network connectivity: `curl -I https://github.com`
- Check runner logs: `sudo journalctl -u actions.runner.* -n 50`

#### Permission Denied Errors

- Verify sudoers configuration: `sudo visudo -c`
- Test sudo access: `sudo -u ghrunner sudo /opt/levelup-source/scripts/deploy.sh`
- Check file permissions on deployment script

#### Deployment Failures

- Verify source repository is up to date
- Check deployment script logs
- Ensure target directories exist and are writable
- Verify Docker socket permissions

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
