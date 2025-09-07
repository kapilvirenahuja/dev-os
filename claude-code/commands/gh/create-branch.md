---
description: "Create and checkout a new git branch"
argument-hint: branch-name, type
---

Create and checkout a new git branch: $1 to handle $2

# Usage
Creates a new git branch from the current branch and switches to it.


# Branch Naming Conventions
- Format: feature/{issue-id}-{descriptive-name}
- Descriptive name: max 15 characters, kebab-case
- Example: feature/27-gh-commands-auto
- Possible options:
    - `feature/`   - New features
    - `bugfix/`    - Bug fixes
    - `hotfix/`    - Critical fixes
    - `chore/`     - Maintenance tasks
    - `docs/`      - Documentation updates
    - `resarch/`   - trying out new things
