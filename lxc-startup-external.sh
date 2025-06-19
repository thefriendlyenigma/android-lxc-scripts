#!/data/data/com.termux/files/usr/bin/sh
# This is a script for the Termux:Boot plugin to mount an ext4-formatted SD card and start an LXC named debian at boot
# This script will only properly function AFTER an LXC named debian has completely been installed, configured with network access, and set to auto-start SSHD.
# tsu must be installed on Termux, as well.
# This must be placed in ~/.termux/boot and set to executable

# mounting the SD card detected as a block device
# to the folder /data/local/debian
sudo mount /dev/block/mmcblk0 /data/local/debian

# mounting cgroups
if ! mountpoint -q /sys/fs/cgroup 2>/dev/null >/dev/null; then
  sudo mkdir -p /sys/fs/cgroup
  sudo mount -t tmpfs -o rw,nosuid,nodev,noexec,relatime cgroup_root /sys/fs/cgroup
fi

for cg in blkio cpu cpuacct cpuset devices freezer memory pids; do
  if ! mountpoint -q "/sys/fs/cgroup/${cg}" 2>/dev/null >/dev/null; then
    sudo mkdir -p "/sys/fs/cgroup/${cg}"
    sudo mount -t cgroup -o "rw,nosuid,nodev,noexec,relatime,${cg}" "${cg}" "/sys/fs/cgroup/${cg}" \
      2>/dev/null >/dev/null
  fi
done

sudo mkdir -p /sys/fs/cgroup/systemd
sudo mount -t cgroup -o none,name=systemd systemd /sys/fs/cgroup/systemd 2>/dev/null >/dev/null

sudo umount -Rl /sys/fs/cgroup/cg2_bpf 2>/dev/null >/dev/null
sudo umount -Rl /sys/fs/cgroup/schedtune 2>/dev/null >/dev/null
# start the lxc named Debian
sudo lxc-start debian
