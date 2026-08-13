FROM mcr.microsoft.com/devcontainers/base:debian-12

# Pre-seed a real (non-symlink) ~/.local/.IdentityService/msal.cache so
# install.sh's build-time pass must back it up to .IdentityService.bak before
# symlinking to /mnt/.IdentityService.
# vscode is the default remote user in the base image.
RUN mkdir -p /home/vscode/.local/.IdentityService && \
    echo '{"pre-existing":"token"}' > /home/vscode/.local/.IdentityService/msal.cache && \
    chown -R vscode:vscode /home/vscode/.local
