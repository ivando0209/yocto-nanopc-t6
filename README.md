# 🚀 Yocto Build for NanoPC-T6

This repository contains the build configuration and scripts for creating a Yocto Linux distribution for the FriendlyElec NanoPC-T6 single board computer based on the Rockchip RK3588 SoC.

## 📋 Overview

The NanoPC-T6 is a powerful ARM64 single board computer featuring:
- Rockchip RK3588 8-core processor (4x Cortex-A76 + 4x Cortex-A55)
- Up to 16GB LPDDR4X RAM
- eMMC storage and microSD card support
- Multiple USB ports, HDMI output, and Ethernet connectivity

This project uses the Yocto Project to build a custom Linux distribution optimized for the NanoPC-T6.

## ⚙️ Prerequisites

This project uses Docker to provide a consistent compilation environment, eliminating the need for manual package installation and configuration.

### 💻 System Requirements
- **OS**: Any Linux distribution with Docker support, Windows with WSL2, or macOS
- **RAM**: Minimum 8GB (16GB+ recommended for faster builds)
- **Storage**: At least 100GB free disk space
- **CPU**: Multi-core processor (more cores = faster builds)

### 📦 Required Software
Install Docker and Docker Compose on your system:

#### 🐧 Ubuntu/Debian:
```bash
# Install Docker
sudo apt update
sudo apt install -y docker.io docker-compose-plugin
sudo systemctl enable docker
sudo systemctl start docker

# Add your user to docker group
sudo usermod -aG docker $USER
# Log out and back in for group changes to take effect
```

#### 🏔️ Arch Linux:
```bash
# Install Docker
sudo pacman -S docker docker-compose
sudo systemctl enable docker
sudo systemctl start docker

# Add your user to docker group
sudo usermod -aG docker $USER
# Log out and back in for group changes to take effect
```

#### 🌐 Other Distributions:
Follow the official Docker installation guide for your distribution: https://docs.docker.com/engine/install/

### 🐳 Docker Environment Setup
The project includes a pre-configured Docker environment with all necessary tools:

- **Base Image**: `ivando0209/build-os:latest` - Contains all Yocto build dependencies
- **User Mapping**: Maps your host user (UID 1000) to avoid permission issues
- **Volume Mounts**: 
  - `$HOME/workspace` → `/home/user/workspace`
  - `$HOME/Documents` → `/home/user/Documents`
- **Persistent Container**: Keeps running for multiple build sessions

## 🚀 Quick Start

### 1️⃣ Start Docker Environment

First, start the Docker container that provides the compilation environment:

```yml
# docker-compose.yml

version: '3.8'

services:
  build-os:
    container_name: ivan-local
    # image: cavliwireless/build-os
    image: ivando0209/build-os:latest
    entrypoint: /bin/bash -c "while true; do sleep 30; done"
    restart: unless-stopped
    user: "1000:1000" # set the user id and group id
    hostname: ivan-local
    network_mode: bridge
    volumes:
      - /etc/localtime:/etc/localtime
      - $HOME/workspace:/home/user/workspace # This is the workspace where the user will be able to access the files in host machine
      - $HOME/Documents:/home/user/Documents # This is the workspace where the user will be able to access the files in host machine
```

```bash
cd /home/ivando/Documents/nanopc-t6

# Start the Docker container with docker-compose
docker-compose -f docker-compose.yml up -d

# Enter the container
docker exec -it ivan-local bash
```

The container will automatically mount your host directories:
- Host `$HOME/Documents` → Container `/home/user/Documents`
- Host `$HOME/workspace` → Container `/home/user/workspace`

### 2️⃣ Clone and Initialize Repository (Inside Container)

```bash
# Navigate to the project directory (inside container)
cd /home/user/Documents/nanopc-t6

# Set Python 2.7 is default for compilation
sudo update-alternatives --config python
# Choose python 2.7

# Initialize repo with the manifest
repo init --depth=1 -u git@github.com:ivando0209/yocto-nanopc-t6.git \
    -m default.xml \
    --repo-url=https://git.codelinaro.org/clo/tools/repo.git \
    --repo-branch=qc-stable

# Sync all repositories (this will take some time)
repo sync -j16
```

### 3️⃣ Set Up Build Environment (Inside Container)

```bash
source source-build-marine-image.sh
```

### 4️⃣ Configure Build (Inside Container)

The build script automatically copy files from **meta-marine/build-conf** to **build-marine/conf**:

#### ⚙️ BitBake Layers Configuration (`conf/bblayers.conf`)
The configuration includes these essential layers:
- **poky/meta**: Core OpenEmbedded functionality
- **poky/meta-poky**: Poky distribution configuration
- **poky/meta-yocto-bsp**: Board support packages
- **meta-rockchip**: Rockchip SoC support layer
- **meta-arm/meta-arm**: ARM architecture support
- **meta-arm/meta-arm-toolchain**: ARM toolchain
- **meta-arm/meta-marine**: Custom image for marine device

#### 🔧 Local Configuration (`conf/local.conf`)
Key settings include:
- **MACHINE**: Set to "nanopc-t6"
- **DISTRO**: Uses "poky" distribution
- **Package Management**: RPM-based packaging
- **Build Optimizations**: Configured for efficient builds

### 5️⃣ Start Build (Inside Container)

```bash
# Build minimal core image (recommended for first build)
bitbake core-image-minimal
```

### 6️⃣ Managing the Docker Environment

```bash
# Check container status
docker-compose ps

# Stop the container
docker-compose down

# View container logs
docker-compose logs build-os

# Restart container if needed
docker-compose restart build-os
```

## 💿 Available Images

You can build different image types depending on your needs (all commands run inside the container):

```bash
# Minimal image (fastest build, basic functionality)
bitbake core-image-minimal

# Minimal image with XFCE desktop
bitbake core-image-minimal

# Base image with more packages
bitbake core-image-base

# Image with development tools
bitbake core-image-full-cmdline

# Image with X11 support
bitbake core-image-x11

# Image with Sato desktop environment
bitbake core-image-sato
```

## 📦 Build Output

After a successful build, you'll find the images in:
```
tmp/deploy/images/nanopc-t6/
```

Key files include:
- `*.wic`: Complete disk image for SD card/eMMC
- `*.wic.xz`: Compressed disk image
- `zImage`: Linux kernel
- `*.dtb`: Device tree blob
- `*rootfs.tar.xz`: Root filesystem archive

## 💾 Flashing to Device

### 🖱️ Using Balena Etcher (Recommended)
1. Install Balena Etcher or use the installed `etcher-bin`
2. Select the `.wic` or `.wic.xz` image file
3. Select your SD card or USB drive
4. Flash the image

### 💻 Using dd (Linux/macOS)
```bash
# Decompress if needed
xz -d your-image.wic.xz

# Flash to SD card (replace /dev/sdX with your device)
sudo dd if=your-image.wic of=/dev/sdX bs=4M status=progress
sync
```

## ⚙️ Configuration Options

### 🎯 Machine-Specific Features
The NanoPC-T6 supports these optional features:
- **U-Boot Environment**: Add `rk-u-boot-env` to `MACHINE_FEATURES`
- **Hardware Video Decoding**: Enabled by default for GStreamer
- **A/B Updates with RAUC**: Available for system updates

### 🛠️ Customization Examples

#### 🔧 Enable Development Tools
Add to `conf/local.conf`:
```bash
EXTRA_IMAGE_FEATURES += "debug-tweaks tools-sdk tools-debug"
```

#### 📦 Add Custom Packages
```bash
IMAGE_INSTALL:append = " your-package-name"
```

#### 🚀 Enable systemd
```bash
INIT_MANAGER = "systemd"
```

## ⚡ Build Performance Tips

### ⚡ Parallel Builds
Optimize for your system:
```bash
# In conf/local.conf
BB_NUMBER_THREADS = "8"    # Number of CPU cores
PARALLEL_MAKE = "-j 8"     # Make jobs
```

### 🗂️ Shared State Cache
Enable for faster rebuilds:
```bash
SSTATE_DIR = "/path/to/shared/sstate-cache"
```

### 📁 Download Directory
Preserve downloads between builds:
```bash
DL_DIR = "/path/to/shared/downloads"
```

## 🛠️ Troubleshooting

### 🐳 Docker-Related Issues

#### ❌ Container Won't Start
```bash
# Check Docker service status
sudo systemctl status docker

# Check if port is already in use
docker ps -a

# Remove existing container if needed
docker-compose down
docker container rm ivan-local
```

#### 🔐 Permission Issues with Mounted Volumes
```bash
# Ensure correct user mapping in docker-compose.yml
# The container runs as user 1000:1000 by default
id # Check your host user ID

# If your user ID is different, update docker-compose.yml:
# user: "YOUR_UID:YOUR_GID"
```

#### 💾 Container Out of Memory
```bash
# Check Docker resource limits
docker stats ivan-local

# Increase Docker memory limits in Docker Desktop settings
# Or add memory limits to docker-compose.yml:
# mem_limit: 16g
```

### 🔧 Build-Related Issues

#### 🔤 UTF-8 Locale Errors
The Docker container is pre-configured with UTF-8 locale support. If you still encounter locale issues:

```bash
# Inside container - verify locale
locale

# If needed, export locale variables
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
```

#### 💽 Disk Space Issues
```bash
# Check available space in container
df -h

# Clean Docker system if needed (on host)
docker system prune -a

# Remove unused build artifacts (inside container)
bitbake -c cleanall RECIPE_NAME
```

#### 🔄 Repo Sync Failures
```bash
# Inside container - retry with verbose output
repo sync -v -j4  # Reduce parallel jobs if network is unstable

# Force sync if repos are corrupted
repo sync --force-sync
```

### ❓ Common Issues

#### Disk Space Issues
Ensure adequate free space:
- Build directory: 50GB+
- Downloads: 20GB+
- Shared state: 30GB+

#### 🐍 Python Errors
Verify Python 3.8+ is selected:
```bash
python --version
sudo update-alternatives --config python
```

### 🆘 Getting Help

1. Check the build logs in `tmp/log/`
2. Review BitBake documentation
3. Consult the meta-rockchip layer documentation
4. Visit the Yocto Project documentation

## 👨‍💻 Development Workflow

### 🐳 Docker Environment Management

The Docker-based development environment provides a consistent build environment across different host systems:

```bash
# Start development session
docker-compose -f docker-compose.yml up -d

# Multiple terminal sessions (open new terminals on host)
docker exec -it ivan-local bash

# Persistent storage - your work is saved on the host
# Container volumes:
# - /home/user/Documents (maps to $HOME/Documents on host)
# - /home/user/workspace (maps to $HOME/workspace on host)

# Clean up when done
docker-compose down
```

### 🏗️ Working with the Build Environment

All development commands should be run inside the Docker container:

```bash
# Enter container
docker exec -it ivan-local bash

# Navigate to project
cd /home/user/Documents/nanopc-t6

# Source build environment (run this in each new terminal session)
source poky/oe-init-build-env
```

### ➕ Adding Custom Recipes
1. Create a custom layer: `bitbake-layers create-layer meta-custom`
2. Add your layer to `conf/bblayers.conf`
3. Create recipes in `meta-custom/recipes-*/`

### 🐧 Kernel Development
```bash
# Configure kernel
bitbake virtual/kernel -c menuconfig

# Build kernel only
bitbake virtual/kernel
```

### 🚢 U-Boot Development
```bash
# Configure U-Boot
bitbake u-boot -c menuconfig

# Build U-Boot
bitbake u-boot
```

## 🏗️ Layer Dependencies

This build configuration uses these key layers:
- **poky**: Core Yocto Project reference distribution
- **meta-openembedded**: Extended functionality
- **meta-rockchip**: Rockchip SoC support for RK3588
- **meta-arm**: ARM processor support

## 🔧 Hardware Support

The meta-rockchip layer provides support for:
- **Boot**: U-Boot bootloader with Rockchip-specific patches
- **Kernel**: Linux kernel with RK3588 device drivers
- **Graphics**: Mali GPU support and display drivers
- **Multimedia**: Hardware video acceleration (VPU)
- **Connectivity**: USB, Ethernet, WiFi, Bluetooth

## 📄 License

This project follows the licensing of its components:
- Yocto Project: Mixed licenses (GPL, MIT, etc.)
- meta-rockchip: MIT License
- Individual recipes: Various open source licenses

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the build
5. Submit a pull request

## 📚 References

- [Yocto Project Documentation](https://docs.yoctoproject.org/)
- [meta-rockchip Layer](https://git.yoctoproject.org/meta-rockchip/)
- [NanoPC-T6 Hardware Documentation](https://wiki.friendlyelec.com/wiki/index.php/NanoPC-T6)
- [Rockchip RK3588 Documentation](https://www.rock-chips.com/a/en/products/RK35_Series/2022/0926/1660.html)
