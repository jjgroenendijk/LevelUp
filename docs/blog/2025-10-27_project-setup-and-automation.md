# Project Setup and Automation

**Date:** October 27, 2025

## Overview

Today marks the start of the LevelUp project. This project pulls together homelab configurations, Docker containers, and automation scripts into one place.

## The Rules

A rules file sets the guidelines for working on this project. Here's what it covers:

**Working Style**
- No emojis in code or documentation
- GitHub Project tracks all work
- Ask questions instead of making assumptions

**Security Practices**
The repository is public. That means being careful with sensitive data. Passwords, API keys, and private network details stay out of commits. Sensitive information goes in `.env` files on the server, never in git.

**Code Organization**
Each change gets its own branch with a clear prefix:
- `feat/` - New functionality
- `fix/` - Bug fixes
- `docs/` - Documentation only
- `build/` - Docker images and builds
- `chore/` - Configuration and maintenance

This follows the Conventional Commits standard that many projects use.

**Documentation Requirements**
Every significant change gets a blog post. Simple English, clear structure, explaining what happened and why.

## GitHub Automation

Several workflows now automate project management tasks.

**Auto-Add to Project**
New issues and pull requests automatically appear in the GitHub Project. No manual adding needed.

How it works:
1. An issue or pull request gets created
2. GitHub Actions kicks in
3. The item shows up in the project board
4. Ready to organize and track

**Auto-Labeling**
Labels get added automatically based on:
- Branch names (`feat/` → enhancement, `fix/` → bug, etc.)
- Changed files (modifications in `containers/` → containers label)
- Issue content (mentions of "phase 1" → phase: 1 label)

This keeps everything organized without manual tagging.

**PR-Issue Linking**
Pull requests automatically link to issues:
- Reference an issue with `#123` in the PR description
- Use `closes #123` or `fixes #123` to auto-close on merge
- GitHub shows the PR status on the linked issue
- When the PR merges, the issue closes automatically

**Label Synchronization**
Labels sync between issues and the project board. Add a priority label, and the project view updates. Filter by area, phase, or type to see what matters.

The GitHub CLI tool added existing issues to the project.

## Next Steps

Two main tasks are in the project:

**Phase 1: Deployment Pipeline**
Setting up automation to sync code from GitHub to the homelab server. Push to main, server pulls changes and updates itself.

**Phase 2: Container Builds**
Building Docker images for custom containers and publishing them for public use.

## Why This Matters

Before this, configurations lived in different places. Scripts were scattered everywhere. Tracking changes was a pain.

Now everything has a home. Changes get tracked. Work is visible. The system updates itself.

This is the foundation. Everything else builds on top of this.
