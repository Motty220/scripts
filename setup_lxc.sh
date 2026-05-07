#!/bin/bash

set -e # Exit on any error

# Error handler
trap 'echo "ERROR: Script failed at line $LINENO"; exit 1' ERR

# Check that the script runs as root
if [ "$EUID" -ne 0 ]; then 
  echo "Please run this script as root (sudo)"
  exit 1
fi

echo "=== Setting up new LXC (modular version for GitHub) ==="

# 1. Get basic input from the user
read -p "Enter new username: " NEW_USER
read -s -p "Enter password for user: " PASSWORD
echo ""

if [ -z "$NEW_USER" ]; then
  echo "ERROR: Username cannot be empty"
  exit 1
fi

# 2. Optional installation questions
read -p "Install Docker? (y/n): " INSTALL_DOCKER
read -p "Install Tailscale? (y/n): " INSTALL_TAILSCALE

# 3. Update system and install basic tools
echo "Updating packages and system..."
apt update && apt upgrade -y || { echo "ERROR: Failed to update packages"; exit 1; }
apt install -y sudo curl wget git vim htop zsh || { echo "ERROR: Failed to install basic tools"; exit 1; }

# 4. Create user and set permissions
echo "Creating user: $NEW_USER..."
if id "$NEW_USER" &>/dev/null; then
  echo "ERROR: User $NEW_USER already exists"
  exit 1
fi

useradd -m -s /bin/zsh "$NEW_USER" || { echo "ERROR: Failed to create user"; exit 1; }
echo "$NEW_USER:$PASSWORD" | chpasswd || { echo "ERROR: Failed to set password"; exit 1; }
usermod -aG sudo "$NEW_USER" || { echo "ERROR: Failed to add user to sudo group"; exit 1; }

# 5. Install Docker (optional)
if [[ "$INSTALL_DOCKER" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh || { echo "ERROR: Failed to download Docker installer"; exit 1; }
    sh get-docker.sh || { echo "ERROR: Failed to install Docker"; exit 1; }
    usermod -aG docker "$NEW_USER" || { echo "ERROR: Failed to add user to docker group"; exit 1; }
    rm get-docker.sh
    echo "Docker installed successfully"
else
    echo "Skipping Docker installation."
fi

# 6. Install Tailscale (optional)
if [[ "$INSTALL_TAILSCALE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "Installing Tailscale..."
    curl -fsSL https://tailscale.com/install.sh | sh || { echo "ERROR: Failed to install Tailscale"; exit 1; }
    echo "Tailscale installed successfully"
else
    echo "Skipping Tailscale installation."
fi

# 7. Set ZSH as default shell
chsh -s /bin/zsh "$NEW_USER" || { echo "ERROR: Failed to set zsh as default shell"; exit 1; }

echo ""
echo "=== Installation completed successfully! ==="
echo "1. Log in as new user: su - $NEW_USER"
if [[ "$INSTALL_TAILSCALE" =~ ^([yY][eE][sS]|[yY])$ ]]; then 
  echo "2. Connect Tailscale: sudo tailscale up"
fi
