#!/bin/bash

# Set values for variables
set -e
ATTACH_DISK $1
MOUNT_POINT $2
JOIN_DOMAIN $3
DOMAIN=$4
DOMAIN_USER=$5
DOMAIN_USER_PASS=$6
SUDO_GROUPS=$7

if $ATTACH_DISK ; then
  dev=""
  mount | grep "sda"
  if [ $? -eq 1 ]
    then dev="sda"
  fi
  mount | grep "sdb"
  if [ $? -eq 1 ]
    then dev="sdb"
  fi
  mount | grep "sdc"
  if [ $? -eq 1 ]
    then dev="sdc"
  fi

  if [ "$dev" = "" ]
    then exit 0
  fi

  echo "n
  p
  1


  w
  " | fdisk /dev/$dev
  mkfs.ext4 -L /data "/dev/${dev}1"
  mkdir /data
  echo "LABEL=$MOUNT_POINT $MOUNT_POINT      ext4    defaults        1 2" >> /etc/fstab
  mount -a
fi

# Join the given realm if requested. Set the given groups to sudoers
if $JOIN_DOMAIN ; then
  # install prerequisite packages to domain join
  yum install sssd realmd oddjob oddjob-mkhomedir adcli samba-common samba-common-tools krb5-workstation openldap-clients policycoreutils-python -y

  # Join the domain
  (realm list | grep $DOMAIN) || echo $DOMAIN_USER_PASS | realm join $DOMAIN -U $DOMAIN_USER

  # Allow interaction with AD objects without the domain suffixes
  sed -i '/use_fully_qualified_names = True/c\use_fully_qualified_names = False' /etc/sssd/sssd.conf 
  systemctl restart sssd

  export OLDIFS= $IFS
  export IFS=";"
  for group in $SUDO_GROUPS; do
    echo "%$group ALL=(ALL)  ALL" >> /etc/sudoers
  done
  export IFS="$OLDIFS"
fi
