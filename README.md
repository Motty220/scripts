# Proxmox LXC Setup Automation 🚀

A collection of automation tools designed to streamline workspace management, specifically focused on the rapid deployment and configuration of LXC containers in Proxmox. This script eliminates repetitive manual setup tasks for new servers.

## Features ✨

*   **System Updates:** Automatically runs a full `apt update && apt upgrade -y`.
*   **User Management:** Creates a new user (e.g., `m220`) with `sudo` privileges and sets up a customized `Zsh` environment.
*   **Secure Credential Handling:** Sets up encrypted passwords in real-time without hardcoding credentials in the script.
*   **Optional Installations:**
    *   🐳 **Docker & Docker Compose:** Full installation including configuration for non-root execution.
    *   🔒 **Tailscale:** Client installation for secure local network connectivity.
*   **Cleanup:** Automatically removes temporary installation files after completion.

## Quick Start (One-Liner) ⚡

Run the following command as `root` in your newly created Debian/Ubuntu LXC container:

```bash
curl -sSL https://raw.githubusercontent.com/Motty220/scripts/main/setup_lxc.sh | bash
```

## Prerequisites

*   A Debian or Ubuntu-based LXC container running on Proxmox.
*   Initial access as the `root` user to run the installation script.

---
*Created by [Motty220](https://github.com/Motty220)*
