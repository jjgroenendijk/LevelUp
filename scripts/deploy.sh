#!/bin/bash

#
# LevelUp Deployment Script
#
# Syncs configuration files from the git repository to the live homelab environment.
# Designed to run via GitHub Actions self-hosted runner or manually.
#
# Repository Structure:
#   /opt/levelup-source/homelab/  -> Source configurations (version controlled)
#   /opt/levelup-runtime/         -> Live service deployment
#   /etc/                         -> System configurations
#   /usr/local/bin/               -> Custom executables
#
# Usage:
#   sudo /opt/levelup-source/scripts/deploy.sh
#

set -euo pipefail

# Color output helpers
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run as root (use sudo)"
   exit 1
fi

# Define paths
REPO_ROOT="/opt/levelup-source"
HOMELAB_DIR="${REPO_ROOT}/homelab"
RUNTIME_DIR="/opt/levelup-runtime"

# Validate source directory exists
if [[ ! -d "${HOMELAB_DIR}" ]]; then
    log_error "Source directory not found: ${HOMELAB_DIR}"
    exit 1
fi

log_info "Starting deployment from ${HOMELAB_DIR}"

# Function to sync directory with rsync
# Args: source_dir, target_dir, description
sync_directory() {
    local source="$1"
    local target="$2"
    local description="$3"
    
    if [[ ! -d "${source}" ]]; then
        log_warn "Source directory not found, skipping: ${source}"
        return 0
    fi
    
    log_info "Syncing ${description}: ${source} -> ${target}"
    
    # Create target directory if it doesn't exist
    mkdir -p "${target}"
    
    # Sync with rsync
    # -a: archive mode (preserves permissions, timestamps, etc.)
    # -v: verbose
    # -h: human-readable
    # --delete: remove files in target that don't exist in source
    # --exclude: skip .git directories and other version control files
    if rsync -avh --delete \
        --exclude='.git' \
        --exclude='.gitignore' \
        --exclude='.gitkeep' \
        --exclude='*.swp' \
        --exclude='*~' \
        "${source}/" "${target}/"; then
        log_info "Successfully synced ${description}"
    else
        log_error "Failed to sync ${description}"
        return 1
    fi
}

# Sync runtime directory (docker-compose configs, service configs)
if [[ -d "${HOMELAB_DIR}/opt/levelup-runtime" ]]; then
    sync_directory \
        "${HOMELAB_DIR}/opt/levelup-runtime" \
        "${RUNTIME_DIR}" \
        "runtime configurations"
fi

# Sync system configurations to /etc
if [[ -d "${HOMELAB_DIR}/etc" ]]; then
    # Be more careful with /etc - only sync if there are actual files
    if [[ -n "$(ls -A ${HOMELAB_DIR}/etc 2>/dev/null)" ]]; then
        sync_directory \
            "${HOMELAB_DIR}/etc" \
            "/etc" \
            "system configurations"
    else
        log_warn "No files in ${HOMELAB_DIR}/etc, skipping"
    fi
fi

# Sync custom scripts to /usr/local/bin
if [[ -d "${HOMELAB_DIR}/usr/local/bin" ]]; then
    if [[ -n "$(ls -A ${HOMELAB_DIR}/usr/local/bin 2>/dev/null)" ]]; then
        sync_directory \
            "${HOMELAB_DIR}/usr/local/bin" \
            "/usr/local/bin" \
            "custom scripts"
        
        # Make all scripts in /usr/local/bin executable
        log_info "Setting executable permissions on scripts in /usr/local/bin"
        chmod +x /usr/local/bin/* 2>/dev/null || true
    else
        log_warn "No files in ${HOMELAB_DIR}/usr/local/bin, skipping"
    fi
fi

log_info "Deployment completed successfully"

# Check if docker-compose files exist and offer to restart services
if [[ -f "${RUNTIME_DIR}/docker-compose.yml" ]]; then
    log_info "Docker Compose configuration detected at ${RUNTIME_DIR}"
    log_info "To restart services, run: cd ${RUNTIME_DIR} && docker compose up -d --force-recreate"
fi

exit 0
