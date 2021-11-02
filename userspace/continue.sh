#/usr/bin/env bash

sudo chmod 777 /sys/bus/platform/devices/soc/1c08000.qcom,pcie/enumerate
echo 1 > /sys/bus/platform/devices/soc/1c08000.qcom,pcie/enumerate
# /data/openpilot/launch_openpilot.sh
