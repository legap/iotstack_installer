#!/usr/bin/env bash
#================================================================================
# Installer script for IOTstack on a raspberry pi
#
# This script combines the recommended steps from these links:
# * https://sensorsiot.github.io/IOTstack/Getting-Started/
# * https://gist.github.com/Paraphraser/d119ae81f9e60a94e1209986d8c9e42f#scripting-iotstack-installations
#================================================================================

# checkout directory for iot-stack git repo
iotStackDir=~/IOTstack

sudo apt-get update
sudo apt-get upgrade -y
sudo apt install -y git curl

# clone or pull the iot-stack git repo
if [ -d ${iotStackDir} ]; then
  git pull
else
  git clone https://github.com/SensorsIot/IOTstack.git ${iotStackDir}
fi

# restict dhcp - patch /etc/dhcpcd.conf with allowinterfaces if required
if [ "$(egrep -c "^allowinterfaces eth*,wlan*" /etc/dhcpcd.conf)" -eq 0 ]; then
  echo "allowinterfaces eth*,wlan*" >>/etc/dhcpcd.conf
fi

# update libseccomp2
sudo apt-key adv --keyserver hkps://keyserver.ubuntu.com:443 --recv-keys 04EE7237B7D453EC 648ACFD622F3D138
echo "deb http://httpredir.debian.org/debian buster-backports main contrib non-free" | sudo tee -a "/etc/apt/sources.list.d/debian-backports.list"
sudo apt update
sudo apt install libseccomp2 -t buster-backports

# install latest docker version
curl -fsSL https://get.docker.com | sh

# add current user to docker and bluetooth groups
sudo usermod -G docker -a "${USER}"
sudo usermod -G bluetooth -a "${USER}"

