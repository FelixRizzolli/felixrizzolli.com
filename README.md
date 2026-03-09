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

The production deployment process is automated with GitHub Actions.
