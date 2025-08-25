FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

COMPATIBLE_MACHINE:nanopc-t6 = "nanopc-t6"

SRC_URI:append:nanopc-t6 = " file://0001-update-device-tree-for-NAVONZ-Board.patch"
SRC_URI:append:nanopc-t6 = " file://0002-fix-gmac1.patch"
SRC_URI:append:nanopc-t6 = " file://0003-gmac-phy-add-reset-pin.patch"
SRC_URI:append:nanopc-t6 = " file://0004-LED-correct-system-led-and-user-led.patch"
SRC_URI:append:nanopc-t6 = " file://0005-pcie30-disable-pcie3.0.patch"

