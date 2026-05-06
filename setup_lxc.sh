#!/bin/bash

# Check that the script runs as root
if [ "$EUID" -ne 0 ]; then 
  echo "Please run this script as root (sudo)"
  exit
fi

echo "=== Setting up new LXC (modular version for GitHub) ==="

# 1. Get basic input from the user
read -p "Enter new username: " NEW_USER
read -s -p "Enter password for user: " PASSWORD
echo ""

# 2. Optional installation questions
read -p "Install Docker? (y/n): " INSTALL_DOCKER
read -p "Install Tailscale? (y/n): " INSTALL_TAILSCALE

# 3. Update system and install basic tools
echo "Updating packages and system..."
apt update && apt upgrade -y
apt install -y sudo curl wget git vim htop zsh # Zsh is the preferred default shell

# 4. Create user and set permissions
echo "Creating user: $NEW_USER..."
useradd -m -s /bin/zsh "$NEW_USER"
echo "$NEW_USER:$PASSWORD" | chpasswd
usermod -aG sudo "$NEW_USER"

# 5. Install Docker (optional)
if [[ "$INSTALL_DOCKER" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    usermod -aG docker "$NEW_USER" # Allows Docker usage without sudo
    rm get-docker.sh
else
    echo "Skipping Docker installation."
fi

# 6. Install Tailscale (optional)
if [[ "$INSTALL_TAILSCALE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "Installing Tailscale..."
    curl -fsSL https://tailscale.com/install.sh | sh
else
    echo "Skipping Tailscale installation."
fi

# 7. Set ZSH as default shell
chsh -s /bin/zsh "$NEW_USER"

echo "=== Installation completed successfully! ==="
echo "1. Log in as new user: su - $NEW_USER"
if [[ "$INSTALL_TAILSCALE" == "y" ]]; then echo "2. Connect Tailscale: sudo tailscale up"; fi
