SUMMARY = "Core image for marine auto pilot system with full command line interface"

# Common targets are:
#     core-image-minimal
#     core-image-full-cmdline
#     core-image-sato
#     core-image-weston
#     core-image-minimal-xfce

# Networking & system tools
IMAGE_INSTALL:append = " \
    dhcpcd iproute2 net-tools ethtool \
    wpa-supplicant iw \
    util-linux parted hdparm nvme-cli smartmontools \
    i2c-tools spidev-test \
    lshw usbutils pciutils \
"

# Audio
IMAGE_INSTALL:append = " \
    alsa-utils pulseaudio pulseaudio-server pavucontrol \
"

# Firmware
IMAGE_INSTALL:append = " \
    linux-firmware linux-firmware-rtl-nic linux-firmware-iwlwifi \
"
# Desktop & GUI
IMAGE_INSTALL:append = " \
    thunar gvfs gvfsd-trash gpicview \
    xterm xfce4-terminal xfce4-panel xfce4-settings xfce4-appfinder ristretto \
    xfce4-pulseaudio-plugin \
    xfce4-whiskermenu-plugin xfce4-power-manager xfce4-notifyd \
    xdg-user-dirs xdg-utils \
"
# Network management
IMAGE_INSTALL:append = " \
    networkmanager network-manager-applet blueman modemmanager \
"

# Python core + packaging
IMAGE_INSTALL:append = " \
    python3 python3-pip python3-modules python3-setuptools python3-wheel \
"

# GTK + Python bindings
IMAGE_INSTALL:append = " \
    gtk+3 gobject-introspection python3-pygobject \
"
# GPS / AIS
IMAGE_INSTALL:append = " \
    gpsd\
"

# Pypilot autopilot system
IMAGE_INSTALL:append = " \
    minicom picocom \
"

# camera
IMAGE_INSTALL:append = " v4l-utils"
IMAGE_INSTALL:append = " gstreamer1.0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good "

IMAGE_INSTALL:append = " \
    python3-pygobject \
    gtk+3 \
    pango \
    gdk-pixbuf \
    python3-opencv \
    python3-bcrypt \
    python3-numpy \
"

IMAGE_INSTALL:append = " python3-pyserial "
IMAGE_INSTALL:append = " git"
IMAGE_INSTALL:append = " zip unzip"
IMAGE_INSTALL:append = " vim"
IMAGE_INSTALL:append = " gedit"

# Exclude unused packages
PACKAGE_EXCLUDE = "xserver-xorg-xvfb"

# Optional: add dev/debug tools (remove in production)
EXTRA_IMAGE_FEATURES ?= "debug-tweaks ssh-server-openssh package-management"
KERNEL_ARGS:append = " pcie_aspm=off"