# GitHub Self-Hosted Runner Setup

Self-hosted runner configuration for automated homelab deployments with security hardening for public repositories.

## Configuration

- **Location**: `/opt/github-runner/`
- **User**: `ghrunner`
- **Repository**: jjgroenendijk/LevelUp (public)
- **Version**: 2.329.0 (auto-updates)
- **Service**: actions.runner.jjgroenendijk-LevelUp.homelab-runner.service

## Security for Public Repository

Self-hosted runners on public repositories are risky because any user can fork and submit malicious PRs. Security controls implemented:

**Workflow Restrictions**:

- Deployment only runs on push to `main` (never on PRs or forks)
- PR validation uses GitHub-hosted runners (ubuntu-latest)
- CODEOWNERS requires owner approval for workflow changes

**Branch Protection** (`main` branch):

- Require PR with 1 approval
- Require passing status checks
- No direct pushes
- Require conversation resolution

**Runner Isolation**:

- Limited sudo (only specific scripts and commands)
- No sensitive data on runner machine
- Same network as services (no external access)

**Repository Settings** (Actions > General):

- Require approval for first-time contributors: Enabled
- Require approval for all outside collaborators: Enabled

## Installation

### Remove Old Runner (if exists at /srv/github-runner)

```bash
sudo systemctl stop actions.runner.*
cd /srv/github-runner
sudo -u ghrunner ./config.sh remove --token REMOVAL_TOKEN
sudo rm -rf /srv/github-runner
```

### Install New Runner

Get registration token: <https://github.com/jjgroenendijk/LevelUp/settings/actions/runners/new>

```bash
# Create user (if not exists)
sudo useradd -r -m -d /opt/github-runner -s /bin/bash ghrunner
sudo passwd -l ghrunner

# Download and extract
sudo -u ghrunner mkdir -p /opt/github-runner
cd /opt/github-runner
sudo -u ghrunner curl -o actions-runner-linux-x64-2.329.0.tar.gz -L \
  https://github.com/actions/runner/releases/download/v2.329.0/actions-runner-linux-x64-2.329.0.tar.gz
sudo -u ghrunner tar xzf actions-runner-linux-x64-2.329.0.tar.gz

# Configure
sudo -u ghrunner ./config.sh \
  --url https://github.com/jjgroenendijk/LevelUp \
  --token YOUR_TOKEN \
  --name homelab-runner \
  --labels self-hosted,Linux,X64,homelab \
  --work _work \
  --unattended

# Install service
sudo ./svc.sh install ghrunner
sudo ./svc.sh start
```

### Configure Sudo Permissions

```bash
sudo tee /etc/sudoers.d/ghrunner > /dev/null <<'EOF'
# Only grant access to specific commands needed for deployment
ghrunner ALL=(ALL) NOPASSWD: /opt/levelup-source/scripts/deploy.sh
ghrunner ALL=(ALL) NOPASSWD: /usr/bin/docker
ghrunner ALL=(ALL) NOPASSWD: /usr/bin/rsync
EOF

sudo chmod 0440 /etc/sudoers.d/ghrunner
sudo visudo -c
```

### Verify

```bash
# Check service
sudo systemctl status actions.runner.jjgroenendijk-LevelUp.homelab-runner.service

# Check logs
sudo journalctl -u actions.runner.* -n 50

# Verify in GitHub: https://github.com/jjgroenendijk/LevelUp/settings/actions/runners
# Should show "homelab-runner" with status "Idle"
```

## Workflow Configuration

`.github/workflows/homelab-sync.yml`:

- Runs on: self-hosted
- Trigger: push to main only
- Condition: `github.ref == 'refs/heads/main'`
- No environment approval (direct deployment)

`.github/workflows/pr-validation.yml`:

- Runs on: ubuntu-latest (GitHub-hosted, never self-hosted)
- Trigger: pull_request
- Validates shell scripts
- Safe for any contributor

## Maintenance

Monitor: `sudo journalctl -u actions.runner.* -f`

Update (auto-updates enabled, manual rarely needed):

```bash
sudo systemctl stop actions.runner.*
cd /opt/github-runner
sudo -u ghrunner ./config.sh remove --token TOKEN
# Download new version and extract
sudo -u ghrunner ./config.sh --url https://github.com/jjgroenendijk/LevelUp --token TOKEN
sudo systemctl start actions.runner.*
```

## Troubleshooting

**Runner not appearing**: `sudo journalctl -u actions.runner.* -n 100`

**Permission denied**: Verify `/etc/sudoers.d/ghrunner` and test `sudo -u ghrunner sudo /opt/levelup-source/scripts/deploy.sh`

**Workflow not running**: Check workflow conditions, branch protection, and that PR is merged to main

## Risk Acceptance

Running self-hosted runner on public repo carries inherent risks. Mitigations:

- Workflow restrictions prevent fork PR execution
- Manual approval required for merges to main
- Limited sudo permissions
- No secrets in repository
- Regular monitoring

Alternative: Make repository private (safer but limits community engagement).
