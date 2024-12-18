#!/bin/bash
# Username: Administrator, vagrant
# Password: vagrant

set -eou pipefail

# Check to see if the host processor supports Virtualisation Extensions
vtxcores=$(egrep -c '(vmx|svm)' /proc/cpuinfo)
if [ $vtxcores -gt 0 ]; then
  # Good News !!
  echo "Host reports "$vtxcores" VT-x cores available. This will probably work..."
else
  # Bad News !!
  echo "Host CPU Reports 0 VT-x cores available, unable to proceed."
  echo "Please enable VT-x or Virtualisation extensios in the underlying host platform and try again."
  exit 0
fi

# Do some necessary preparation of the environment
chown root:kvm /dev/kvm
/usr/sbin/libvirtd --daemon
/usr/sbin/virtlogd --daemon
cd /vagrant


# Gather and prepare the data we need from the vagrant environment for use setting up the vagrant anvironment.
RESULT="$(vagrant --machine-readable box list)"
box_name=$(echo $(echo "$RESULT" | grep name | sed 's/^.*,//g' | sed 's/[[:space:]]*$//' | sed 's/\//-VAGRANTSLASH-/1'))
box_arch=$(echo $(echo "$RESULT" | grep arch | sed 's/^.*,//g' | sed 's/[[:space:]]*$//'))
box_prov=$(echo $(echo "$RESULT" | grep prov | sed 's/^.*,//g' | sed 's/[[:space:]]*$//'))
box_ver=$(echo $(echo "$RESULT"  | grep vers | sed 's/^.*,//g' | sed 's/[[:space:]]*$//'))

# Build up the necessary strings we need
if [ $box_arch = "n/a" ]; then
  AA=$box_name"/"$box_ver"/"$box_prov
else
  AA=$box_name"/"$box_ver"/"$box_arch"/"$box_prov
fi
AA=$(echo "$AA" | sed 's/[[:space:]]*$//')

CC=$box_name"_vagrant_box_image_"$box_ver"_box.img"
CC=$(echo "$CC" | sed 's/[[:space:]]*$//')

#  Assuming this might not be the first run of this script, check and then link the box image to the vagrant store for use by the box when starting up.
if ! test -f  /root/.vagrant.d/boxes/"$AA"/box.img; then
  if test -f  /var/lib/libvirt/images/"$CC"; then
    echo "Linking Vagrant Image file with box source folder."
    ln -s /var/lib/libvirt/images/"$CC"  /root/.vagrant.d/boxes/"$AA"/box.img
  fi
fi


# In case this container has been run previously, and there is a Vagrantfile in the /vagrant folder, then we should 
#  support th euser by passing environment variables into it to set the CPU/RAM/DISK requested by the user by way of
#  the ENVironment variables passed from docker.
if test -f Vagrantfile.orig; then
  mv Vagrantfile.orig Vagrantfile
fi
if test -f Vagrantfile; then
  sed "s/config.vm.box_check_update.*/config.vm.box_check_update = false/g" Vagrantfile > Vagrantfile.out
  mv Vagrantfile.out Vagrantfile
  envsubst '$CPU,$MEMORY,$DISK_SIZE' < Vagrantfile > Vagrantfile.tmp
  mv Vagrantfile Vagrantfile.orig
  mv Vagrantfile.tmp Vagrantfile
#  vagrant destroy -f
  vagrant up
fi

exec "$@"