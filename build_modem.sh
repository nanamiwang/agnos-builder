#!/bin/bash -e

# Make sure we're in the correct spot
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
cd $DIR

BUILD_DIR="$DIR/build"
OUTPUT_DIR="$DIR/output"

MODEM_DIR="$BUILD_DIR/agnos-modem"
MODEM_IMAGE="$BUILD_DIR/modem.img.raw"
MODEM_IMAGE_SIZE=80M
SPARSE_IMAGE="$BUILD_DIR/modem.img"

# Create temp dir if non-existent
mkdir -p $BUILD_DIR $OUTPUT_DIR

# Create filesystem ext4 image
echo "Creating empty filesystem"
fallocate -l $MODEM_IMAGE_SIZE $MODEM_IMAGE
mkfs.ext4 $MODEM_IMAGE > /dev/null

# Mount filesystem
echo "Mounting empty filesystem"
mkdir -p $MODEM_DIR
sudo umount -l $MODEM_DIR > /dev/null || true
sudo mount $MODEM_IMAGE $MODEM_DIR

# Extract image
cd $MODEM_DIR
sudo cp -v -r -p /mnt/disk1/tmp/* ./ || true
sudo cp -v -p $DIR/userspace/firmware_pixel3/wlanmdsp.mbn ./image/
cd $DIR

# Unmount image
echo "Unmount filesystem"
sudo umount -l $MODEM_DIR

# Sparsify
echo "Sparsify image"
img2simg $MODEM_IMAGE $SPARSE_IMAGE
mv $SPARSE_IMAGE $OUTPUT_DIR

echo "Done!"
