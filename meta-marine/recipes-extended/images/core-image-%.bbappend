SUMMARY = "Core image for marine auto pilot system with full command line interface"

# Common targets are:
#     core-image-minimal
#     core-image-full-cmdline
#     core-image-sato
#     core-image-weston
#     core-image-minimal-xfce

IMAGE_INSTALL:append = " \
	dhcpcd \
	iproute2 \
	net-tools \
	ethtool \
	wpa-supplicant \
	iw \
	networkmanager \
	util-linux \
	parted \
	hdparm \
	nvme-cli \
	smartmontools \
	i2c-tools \
	spidev-test \
	alsa-utils \
	pulseaudio \
	lshw \
"

# Exclude the X Virtual Framebuffer server package from being installed
# This prevents xserver-xorg-xvfb (used for headless X11 testing/automation) 
# from being included in the final image, reducing image size and attack surface
PACKAGE_EXCLUDE = "xserver-xorg-xvfb"
