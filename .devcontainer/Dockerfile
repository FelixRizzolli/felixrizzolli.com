FROM mcr.microsoft.com/devcontainers/typescript-node:24

# Use bash as the shell for RUN commands
SHELL ["/bin/bash", "-lc"]

RUN <<BASH
set -euo pipefail

echo "INSTALL FELIXRIZZOLLI DEVCONTAINER IMAGE"

# Configure Bash
#  --> Disable Bash's bracket paste mode
echo "bind 'set enable-bracket-paste off'" >> ~/.bashrc
#  --> Always show hidden files in ls and colorize the output
echo "alias ls='ls -a --color=auto'" >> ~/.bashrc

# Configure Git
#  --> Ensure that git treats /workspace as a safe directory to avoid permission-related issues.
git config --global --add safe.directory /workspace

BASH

EXPOSE 3000
EXPOSE 6006
EXPOSE 3001