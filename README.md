# felixrizzolli.com - Monorepo

## 🧩 Subprojects

| Domain | Status | Description | Technologies        | GitHub Repository |
|---|---|---|---------------------|---|
| [api.felixrizzolli.com](https://api.felixrizzolli.com) | live | API backend for content, admin and public APIs | Payload CMS, NextJS | [felixrizzolli.com_api](https://github.com/FelixRizzolli/felixrizzolli.com_api) |
| [www.felixrizzolli.com](https://www.felixrizzolli.com) | draft | Personal website / portfolio | TBD                 | [felixrizzolli.com_www](https://github.com/FelixRizzolli/felixrizzolli.com_www) |
| [docs.felixrizzolli.com](https://docs.felixrizzolli.com) | draft | Personal documentation site | TBD                 | [felixrizzolli.com_docs](https://github.com/FelixRizzolli/felixrizzolli.com_docs) |
| [traveling.felixrizzolli.com](https://traveling.felixrizzolli.com) | draft | Traveling blog and trip reports | TBD                 | [felixrizzolli.com_traveling](https://github.com/FelixRizzolli/felixrizzolli.com_traveling) |
| [wedding.felixrizzolli.com](https://wedding.felixrizzolli.com) | beta | Wedding website image gallery and info | Nuxt 4, shadcn-vue  | [felixrizzolli.com_wedding](https://github.com/FelixRizzolli/felixrizzolli.com_wedding) |

## 🏗️ Architecture

### Technical Project Overview

This project demonstrates a modern full-stack web architecture, optimized for maintainability, scalability, and 
developer experience:

- **Backend: Payload CMS**  
  Payload CMS offers a modern, headless CMS solution with a focus on developer experience and extensibility. It supports 
  REST and GraphQL APIs, custom admin interfaces, and robust access control.
- **Frontend**  
  Each frontend application has its own codebase, allowing for independent development and deployment. The wedding 
  website is built with Nuxt 4, while the other frontends are currently in draft status and therefore their tech stack 
  is not yet defined.
- **Monorepo Structure**  
  The monorepo structure allows for shared code and resources across applications, while still maintaining clear 
  boundaries between them. This promotes code reuse and simplifies dependency management. All JavaScript/TypeScript
  subprojects in the repo use pnpm workspaces (see the `pnpm-lock.yaml` files). Using pnpm across the monorepo brings
  several advantages:
  - Fast, deterministic installs through a content-addressable store and a single lockfile for the workspace.
  - Disk space savings by sharing packages between workspaces rather than duplicating them.
  - Strict, predictable node_modules layout which helps catch dependency errors earlier.
  - First-class workspace support for easy cross-package development and local linking without publishing.
- **Development Environment: Devcontainer (VS Code & JetBrains)**  
  The project leverages Devcontainer-based development environments to provide consistent, containerized developer
  environments that eliminate "works on my machine" issues and speed up onboarding. The devcontainer supports both VS
  Code and JetBrains IDEs (WebStorm is recommended). Note that JetBrains IDEs include many built-in developer tools
  (debuggers, test runners, language support), while VS Code relies more on extensions for some of that functionality.
  Because of these differences, IDE-specific features or integrations may behave differently — the container provides
  the same runtime dependencies and command-line tooling inside the development container, but the in-IDE experience
  won't be identical between editors. Use your preferred IDE's Dev Container / Remote Development support to open the
  project.
  
### Project Structure

```
felixrizzolli.com/
├── apps/
│   ├── api/           # API backend
│   ├── www/           # Personal website
│   ├── docs/          # Personal documentation
│   ├── traveling/     # Traveling blog
│   └── wedding/       # Wedding website image gallery
├── infrastructure/    # Docker Compose for prod/staging
├── terraform/         # Infrastructure as Code
├── .devcontainer/     # Development environment
└── scripts/           # Automation scripts for production
```

## 🛠️ Development

### Requirements

- VSCode or JetBrains IDE (WebStorm recommended)
- Docker

### Getting Started

The simplest way to develop in this project is to launch the devcontainer from VS Code or a JetBrains IDE (WebStorm is
recommended). The devcontainer will install all required dependencies automatically and provide a consistent
runtime for all subprojects.

## 🚀 Deployment

The production deployment process is fully automated with GitHub Actions.
Container images are built and pushed to the
[GitHub Container Registry (GHCR)](https://ghcr.io) by each sub-project's
own CI pipeline. **This repository only handles server provisioning and service
deployments — it never builds images.**

### Workflows

| Workflow | File | Trigger | Purpose |
|---|---|---|---|
| Server Initialization | [`server-init.yml`](.github/workflows/server-init.yml) | Manual | Clones this repo on a fresh server and runs the one-time setup |
| Automated Deployment  | [`deploy.yml`](.github/workflows/deploy.yml)           | Automatic / Manual | Deploys a specific service by pulling its latest image |

### Deployment Flow

```
Sub-project repository                    This repository
──────────────────────────────────────    ──────────────────────────────────────
1. Code is pushed to main
2. Build workflow runs:
   - Builds Docker image
   - Pushes to GHCR with tags:
       :latest
       :sha-<commit>
   - Dispatches repository_dispatch  ──▶  3. deploy.yml is triggered
        event-type: <service>-updated         - Assembles .env.prod from
        client-payload:                          GitHub secrets + variables
          version: sha-<commit>               - Uploads .env.prod to server
                                              - Runs deploy.sh <service> <version>
                                                - Pulls new image
                                                - Restarts container
                                                - Waits for health check ✓
                                                - Rolls back on failure  ✗
```

### Initial Server Setup

Run **once** on a fresh Hetzner server. Before triggering the workflow, make
sure all secrets and variables are configured (see [Requirements](#requirements)
below).

1. Go to **Actions → Server Initialization → Run workflow**.

The workflow will:

- Clone this repository to `/var/www/felixrizzolli.com` on the server
- Upload `.env.prod` assembled from your GitHub secrets and variables
- Create all required Docker volume directories
- Start the shared Traefik reverse proxy *(only if `WITH_PROXY=true`)*

### Redeploying Manually

Go to **Actions → Automated Deployment → Run workflow**, pick the service,
and optionally enter a specific image tag. Leave the version field empty to
redeploy the `:latest` image.

---

### Requirements

> Configure the following in the **`production`** GitHub environment before
> running either workflow.
> Navigate to **Settings → Environments → production**.

#### Variables

Non-sensitive configuration values. Visible in workflow logs.

| Variable | Example | Description |
|---|---|---|
| `WITH_PROXY` | `true` | `true` if this project owns and starts the shared Traefik reverse proxy. Set to `false` if another project on the same server already manages it. |
| `ACME_EMAIL` | `you@example.com` | Email address for Let's Encrypt certificate expiry notifications. |
| `TRAEFIK_DASHBOARD_DOMAIN` | `traefik.example.com` | Hostname for the Traefik dashboard. |
| `API_DOMAIN` | `api.example.com` | Public hostname of the API service. |
| `WWW_DOMAIN` | `example.com` | Root hostname of the main website. The `www.` subdomain is added automatically. |
| `DOCS_DOMAIN` | `docs.example.com` | Hostname of the documentation site. |
| `WEDDING_DOMAIN` | `wedding.example.com` | Hostname of the wedding website. |
| `TRAVELING_DOMAIN` | `traveling.example.com` | Hostname of the traveling blog. |

#### Secrets

Sensitive values, encrypted by GitHub and never exposed in logs.

| Secret | Description |
|---|---|
| `PROD_HOST` | IP address or hostname of the production server. |
| `PROD_USER` | SSH login username on the production server. |
| `SSH_PRIVATE_KEY` | Private SSH key for authenticating with the server. The corresponding public key must be in `~/.ssh/authorized_keys` on the server. |
| `PROD_ENV` | Full content of the `.env.prod` file. Contains all remaining runtime secrets. See the template below. |

#### `PROD_ENV` Secret Template

Use [`infrastructure/.env`](infrastructure/.env) as your template — it
documents every required variable with example values and notes which ones
are managed separately as GitHub environment variables. Copy its contents
into the `PROD_ENV` secret and replace the `changeme` placeholders with
your real values.

> **Note:** The `*_DOMAIN` and `WITH_PROXY` variables are included in that
> file for documentation and standalone use. In CI they are **overridden**
> by the GitHub environment variables configured above, so you don't need
> to keep them in sync manually.
