FROM mcr.microsoft.com/devcontainers/base:debian-12

# Pre-seed a real (non-symlink) ~/.codex config dir so install.sh's build-time
# pass must back it up to .codex.bak before symlinking to /mnt/.codex.
# vscode is the default remote user in the base image.
RUN mkdir -p /home/vscode/.codex && \
    echo '{"token":"pre-existing"}' > /home/vscode/.codex/config.json && \
    chown -R vscode:vscode /home/vscode/.codex
