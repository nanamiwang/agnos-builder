#!/bin/bash -e

# Make sure we're in the correct spot
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
cd $DIR

BUILD_DIR="$DIR/build"
OUTPUT_DIR="$DIR/output"

SYSTEMRW_DIR="$BUILD_DIR/agnos-systemrw"
SYSTEMRW_IMAGE="$BUILD_DIR/SYSTEMRW.img.raw"
SYSTEMRW_IMAGE_SIZE=16384K
SPARSE_IMAGE="$BUILD_DIR/SYSTEMRW.img"

# Create temp dir if non-existent
mkdir -p $BUILD_DIR $OUTPUT_DIR

# TODO: this needs to be re-done sometimes
# Register qemu multiarch if not done
if [ ! -f $DIR/.qemu_registered ] && [ "$(uname -p)" != "aarch64" ]; then
  docker run --rm --privileged multiarch/qemu-user-static:register
  touch $DIR/.qemu_registered
fi

# Create filesystem ext4 image
echo "Creating empty filesystem"
fallocate -l $SYSTEMRW_IMAGE_SIZE $SYSTEMRW_IMAGE
mkfs.ext4 $SYSTEMRW_IMAGE > /dev/null

# Sparsify
echo "Sparsify image"
img2simg $SYSTEMRW_IMAGE $SPARSE_IMAGE
mv $SPARSE_IMAGE $OUTPUT_DIR

echo "Done!"
