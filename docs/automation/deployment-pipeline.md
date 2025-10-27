# Deployment Pipeline

Automated configuration deployment system for the LevelUp homelab infrastructure.

## Overview

The deployment pipeline automatically synchronizes configuration files from the git repository to the live homelab environment. Changes pushed to the `main` branch trigger automated deployment via a self-hosted GitHub Actions runner.

## Architecture

### Directory Structure

```
/opt/levelup-source/          # Git repository (version controlled)
├── homelab/                  # Source configurations
│   ├── etc/                 # System configurations
│   ├── usr/local/bin/       # Custom scripts
│   └── opt/levelup-runtime/ # Service configurations
└── scripts/
    └── deploy.sh            # Deployment automation

/opt/levelup-runtime/         # Live deployment (runtime data)
├── docker-compose*.yml       # Service orchestration
├── .env                     # Environment variables (not tracked)
└── {service}/               # Service configurations and data
```

### Components

#### 1. Source Repository

Location: `/opt/levelup-source/`

The version-controlled git repository contains all configuration files in a filesystem hierarchy under `homelab/` that mirrors the target deployment locations.

#### 2. Deployment Script

Location: `/opt/levelup-source/scripts/deploy.sh`

Bash script that synchronizes configurations from the repository to live locations using `rsync`. Handles:
- Directory creation
- File synchronization with preservation of permissions
- Exclusion of version control files
- Validation and error handling

#### 3. GitHub Actions Workflow

Location: `.github/workflows/homelab-sync.yml`

Automated workflow that:
- Triggers on push to `main` branch affecting `homelab/` or deployment scripts
- Runs on self-hosted runner with elevated permissions
- Executes deployment script
- Restarts Docker Compose services if configurations changed
- Reports deployment status

#### 4. Self-Hosted Runner

Location: `/opt/github-runner/`

GitHub Actions runner service that:
- Monitors repository for workflow triggers
- Executes workflows with `ghrunner` user permissions
- Has passwordless sudo access to deployment script
- Provides secure execution environment

## Deployment Flow

1. **Change Creation**: Configuration files modified in `homelab/` directory
2. **Commit**: Changes committed to feature branch following Conventional Commits
3. **Pull Request**: PR created and reviewed (automated validation runs)
4. **Merge**: PR merged to `main` branch
5. **Trigger**: GitHub Actions detects push to `main` affecting `homelab/`
6. **Execution**: Self-hosted runner checks out latest code
7. **Validation**: Deployment script existence and permissions verified
8. **Sync**: Configuration files synchronized to target locations
9. **Restart**: Docker Compose services restarted with new configurations
10. **Notification**: Workflow status reported

## Usage

### Making Configuration Changes

#### 1. Create Feature Branch

```bash
cd /opt/levelup-source
git checkout main
git pull
git checkout -b chore/update-service-config
```

#### 2. Edit Configurations

Edit files in the appropriate `homelab/` subdirectory:

```bash
# Service configurations
vim homelab/opt/levelup-runtime/traefik/traefik.yml

# System configurations
vim homelab/etc/systemd/system/backup.service

# Custom scripts
vim homelab/usr/local/bin/levelup-backup
chmod +x homelab/usr/local/bin/levelup-backup
```

#### 3. Test Locally (Optional)

```bash
sudo /opt/levelup-source/scripts/deploy.sh
```

#### 4. Commit and Push

```bash
git add homelab/
git commit -m "chore: update traefik SSL configuration"
git push origin chore/update-service-config
```

#### 5. Create Pull Request

Create PR via GitHub interface or CLI, ensuring it references an issue.

#### 6. Merge to Main

After approval and checks pass, merge the PR. Deployment will automatically execute.

### Manual Deployment

For testing or emergency deployments:

```bash
cd /opt/levelup-source
git pull origin main
sudo /opt/levelup-source/scripts/deploy.sh
```

Restart services if needed:

```bash
cd /opt/levelup-runtime
docker compose up -d --force-recreate
```

## Configuration Tracking

### What Gets Tracked

Files in the `homelab/` directory that should be version controlled:

- YAML/TOML/INI configuration files
- Docker Compose files
- Shell scripts
- Systemd unit files
- Network configurations
- `.env.example` templates

### What Gets Ignored

Files that should NOT be tracked (specified in `.gitignore`):

- `.env` files (contain secrets)
- `data/` directories
- Database files (`.db`, `.sqlite`)
- Log files (`.log`)
- SSL certificates and private keys
- Binary files
- Cache directories

## Deployment Script Details

### Safety Features

- **Validation**: Verifies source directory exists before proceeding
- **Atomic Operations**: Uses `rsync` for reliable synchronization
- **Permission Preservation**: Maintains file permissions and ownership
- **Backup**: `rsync` creates backups before overwriting (optional)
- **Logging**: Colored output indicates info/warning/error states

### Rsync Options

The script uses the following `rsync` flags:

- `-a`: Archive mode (preserves permissions, timestamps, symlinks)
- `-v`: Verbose output
- `-h`: Human-readable sizes
- `--delete`: Remove files in target that don't exist in source

### Exclusions

Automatically excludes:
- `.git` directories
- `.gitignore` files
- `.gitkeep` files
- Swap files (`.swp`, `*~`)

## Security Considerations

### Repository Access

- Repository uses SSH authentication
- Runner has read-only deploy key
- No secrets stored in repository
- Public repository requires careful content review

### Execution Permissions

- Runner user (`ghrunner`) has limited sudo access
- Only specific scripts can be executed with elevated privileges
- Deployment script validates inputs
- No arbitrary command execution

### Secret Management

- Real `.env` files never committed
- `.env.example` provides template structure
- Secrets configured directly on host or via GitHub Secrets
- Environment variables passed securely to containers

## Monitoring and Troubleshooting

### Viewing Workflow Status

Check GitHub Actions interface for workflow execution status and logs.

### Checking Runner Status

```bash
sudo systemctl status actions.runner.*
sudo journalctl -u actions.runner.* -f
```

### Manual Deployment Testing

```bash
cd /opt/levelup-source
git pull
sudo /opt/levelup-source/scripts/deploy.sh
```

### Common Issues

#### Deployment Script Fails

- Check script permissions: `ls -l /opt/levelup-source/scripts/deploy.sh`
- Verify source directory exists: `ls -ld /opt/levelup-source/homelab`
- Check rsync availability: `which rsync`

#### Services Not Restarting

- Verify Docker Compose files: `cd /opt/levelup-runtime && docker compose config`
- Check Docker service: `systemctl status docker`
- Review container logs: `docker compose logs`

#### Permission Denied

- Verify sudoers configuration: `sudo visudo -c`
- Test runner permissions: `sudo -u ghrunner sudo /opt/levelup-source/scripts/deploy.sh`

## Best Practices

### Configuration Changes

1. Always work in feature branches
2. Test changes locally when possible
3. Use descriptive commit messages following Conventional Commits
4. Reference related issues in PR descriptions
5. Request review before merging to `main`

### Service Updates

1. Review configuration changes in PR diff
2. Plan for potential service downtime
3. Monitor service health after deployment
4. Keep `.env.example` updated with new variables

### Rollback Procedures

If deployment causes issues:

```bash
cd /opt/levelup-source
git revert HEAD
git push origin main
# Deployment will automatically run with reverted configuration
```

For immediate rollback:

```bash
cd /opt/levelup-source
git checkout main~1  # Previous commit
sudo /opt/levelup-source/scripts/deploy.sh
```

## Future Enhancements

Potential improvements to the deployment pipeline:

- Pre-deployment validation hooks
- Configuration syntax checking
- Automated backup before deployment
- Rollback automation on failure
- Deployment notifications (Slack, email)
- Staging environment testing
- Blue-green deployment for zero downtime

## References

- [GitHub Actions Workflows](../.github/workflows/homelab-sync.yml)
- [Deployment Script](../scripts/deploy.sh)
- [Runner Setup Guide](./github-runner-setup.md)
