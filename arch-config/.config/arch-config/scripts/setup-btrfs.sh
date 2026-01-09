#!/usr/bin/env bash

# Enable and start grub btrfs service
systemctl enable --now grub-btrfsd.service
