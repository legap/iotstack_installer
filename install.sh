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

echo "================================================================================"
echo "updating raspbian and installing required tools"
echo "--------------------------------------------------------------------------------"
sudo apt-get update
sudo apt-get upgrade -y
sudo apt install -y git curl

echo "================================================================================"
echo "creating or updating git repo for IOTstack"
echo "--------------------------------------------------------------------------------"
if [ -d ${iotStackDir} ]; then
  git pull
else
  git clone https://github.com/SensorsIot/IOTstack.git ${iotStackDir}
fi

if [ "$(grep --perl-regexp "^allowinterfaces\w*(?=.*eth.*)(?=.*wlan.*)"  /etc/dhcpcd.conf)" -eq 0 ]; then
  echo "================================================================================"
  echo "restricting dhcp access to avoid conflicts between docker and dhcpd"
  echo "--------------------------------------------------------------------------------"
  echo "allowinterfaces eth*,wlan*" >>/etc/dhcpcd.conf
fi

debianBackportsSource="/etc/apt/sources.list.d/debian-backports.list"
if [ ! -f ${debianBackportsSource} ]; then
  echo "================================================================================"
  echo "update library libseccomp2 to avoid problems with alpine linux"
  echo "--------------------------------------------------------------------------------"
  sudo apt-key adv --keyserver hkps://keyserver.ubuntu.com:443 --recv-keys 04EE7237B7D453EC 648ACFD622F3D138
  echo "deb http://httpredir.debian.org/debian buster-backports main contrib non-free" | sudo tee -a ${debianBackportsSource}
  sudo apt update
  sudo apt install libseccomp2 -t buster-backports
fi

# install latest docker version
echo "================================================================================"
echo "install latest docker and docker-compose version"
echo "--------------------------------------------------------------------------------"
curl -fsSL https://get.docker.com | sh

# add current user to docker and bluetooth groups
echo "================================================================================"
echo "add current user to required groups"
echo "--------------------------------------------------------------------------------"
sudo usermod -G docker -a "${USER}"
sudo usermod -G bluetooth -a "${USER}"
