# GitHub Automation

## Overview

The LevelUp project uses GitHub Actions workflows to automate project management tasks. This automation reduces manual work and ensures consistent processes across all issues and pull requests.

## Automated Workflows

### Auto-Add to Project

New issues and pull requests are automatically added to the GitHub Project board.

**Implementation:** `.github/workflows/add-to-project.yml`

**How it works:**
1. Issue or PR is created
2. Workflow triggers via webhook
3. GitHub Actions adds item to project using the `actions/add-to-project` action
4. Item appears in project board with default status

**Configuration:**
- Project URL: `https://github.com/users/jjgroenendijk/projects/4`
- Requires `ADD_TO_PROJECT_PAT` secret with `project` scope

### Auto-Labeling

Labels are applied automatically based on multiple criteria.

**Implementation:** `.github/workflows/auto-label.yml` and `.github/labeler.yml`

**Branch-based labeling:**
- `feat/` branches → `enhancement` label
- `fix/` branches → `bug` label
- `docs/` branches → `documentation` label
- `build/` branches → `build` label
- `ci/` branches → `ci` label
- `chore/` branches → `maintenance` label
- `perf/` branches → `performance` label
- `refactor/` branches → `refactor` label

**File-based labeling:**
- Changes in `containers/` → `containers` label
- Changes in `.github/workflows/` → `ci` label
- Changes in `homelab/` → `homelab` label
- Changes in `scripts/` → `scripts` label
- Changes in `docs/` or `*.md` → `documentation` label

**Content-based labeling (issues only):**
- Title/body contains "phase 1" → `phase: 1` label
- Title/body contains "phase 2" → `phase: 2` label
- Title/body contains "urgent" or "critical" → `priority: high` label
- Keywords like "deployment", "container", "service" → corresponding `area:` labels

### PR-Issue Linking

Pull requests are automatically linked to referenced issues.

**Implementation:** `.github/workflows/link-pr-issues.yml`

**Functionality:**
- Detects issue references in PR body (`#123`)
- Identifies closing keywords (`closes #123`, `fixes #123`, `resolves #123`)
- GitHub automatically links PRs to issues
- Shows PR status on linked issues

### Auto-Close Issues

Issues are automatically closed when linked PRs merge.

**Implementation:** `.github/workflows/close-issues.yml`

**How it works:**
1. PR with `closes #123` in description merges
2. GitHub automatically closes issue #123
3. Workflow adds confirmation comment: "✅ Closed by PR #X"

### PR Validation

Pull requests must meet requirements before merging.

**Implementation:** `.github/workflows/pr-validation.yml`

**Validation checks:**
- PR must reference at least one issue
- PR cannot be in draft mode
- All checks must pass before merge is allowed

**Failure handling:**
- Failed validation adds comment to PR explaining requirements
- Sets commit status to failure, blocking merge

## Branch Protection

Main branch is protected with the following rules:

**Requirements:**
- Pull requests required (no direct pushes)
- `PR Validation` status check must pass
- Pull request reviews recommended but not enforced

**Configuration:**
```bash
gh api repos/jjgroenendijk/LevelUp/branches/main/protection \
  --method PUT \
  --field required_status_checks[strict]=true \
  --field required_status_checks[contexts][]=PR\ Validation
```

## Labels

### Standard Labels
- `enhancement` - New features
- `bug` - Bug fixes
- `documentation` - Documentation changes
- `build` - Build system changes
- `ci` - CI/CD changes
- `maintenance` - Maintenance tasks
- `performance` - Performance improvements
- `refactor` - Code refactoring

### Project Labels
- `homelab` - Homelab configuration changes
- `containers` - Container/Docker changes
- `compose` - Docker compose changes
- `scripts` - Script changes
- `infrastructure` - Infrastructure configs

### Organization Labels
- `phase: 1` - Phase 1 tasks
- `phase: 2` - Phase 2 tasks
- `priority: high` - High priority items
- `area: deployment` - Deployment related
- `area: containers` - Container related
- `area: services` - Service configuration
- `area: infrastructure` - Infrastructure/system configs

## Testing

All workflows were validated with test issues and pull requests:

**Test Issue (#3):**
- Automatically added to project ✓
- Auto-labeled with `phase: 1` ✓
- Referenced in test PR ✓
- Closed automatically on PR merge ✓

**Test PR (#4):**
- Added to project automatically ✓
- Validated successfully ✓
- Linked to issue #3 ✓
- Triggered auto-close on merge ✓

**Fix PR (#5):**
- File-based labeling tested ✓
- All workflows passed ✓
- Branch protection enforced ✓

## Secrets Required

- `ADD_TO_PROJECT_PAT` - Personal Access Token with `project` and `repo` scopes for project automation
- `GITHUB_TOKEN` - Automatically provided by GitHub Actions for most operations

## Maintenance

**Adding new labels:**
```bash
gh label create "label-name" --description "Description" --color "HEX" --repo jjgroenendijk/LevelUp
```

**Updating labeler configuration:**
Edit `.github/labeler.yml` following the actions/labeler@v5 format:
```yaml
label-name:
  - changed-files:
    - any-glob-to-any-file: 'path/pattern/**'
```

**Modifying branch protection:**
Use GitHub CLI or web interface to update protection rules.
