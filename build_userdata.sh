#!/bin/bash -e

# Make sure we're in the correct spot
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
cd $DIR

BUILD_DIR="$DIR/build"
OUTPUT_DIR="$DIR/output"

USERDATA_DIR="$BUILD_DIR/agnos-userdata"
USERDATA_IMAGE="$BUILD_DIR/userdata.img.raw"
#USERDATA_IMAGE_SIZE=3170316288
USERDATA_IMAGE_SIZE=35428300K
SPARSE_IMAGE="$BUILD_DIR/userdata.img"

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
fallocate -l $USERDATA_IMAGE_SIZE $USERDATA_IMAGE
mkfs.ext4 $USERDATA_IMAGE > /dev/null

# Mount filesystem
echo "Mounting empty filesystem"
mkdir -p $USERDATA_DIR
sudo umount -l $USERDATA_DIR > /dev/null || true
sudo mount $USERDATA_IMAGE $USERDATA_DIR

cd $USERDATA_DIR
echo "Copying openpilot src"
sudo cp -r $DIR/../openpilot ./

sudo bash -c "ln -sf /data/openpilot pythonpath"

cd $DIR

# Unmount image
echo "Unmount filesystem"
sudo umount -l $USERDATA_DIR

# Sparsify
echo "Sparsify image"
img2simg $USERDATA_IMAGE $SPARSE_IMAGE
mv $SPARSE_IMAGE $OUTPUT_DIR

echo "Done!"
