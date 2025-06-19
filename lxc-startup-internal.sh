#!/data/data/com.termux/files/usr/bin/sh
# Termux Boot Script to start debian LXC at boot
# This can only be done AFTER LXC is all setup and LXC is configured to auto-start SSH on boot
# tsu must be installed
# This must be placed in ~/.termux/boot and set to executable

# mount cgroups
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

# remount /data with suid option to allow use of sudo
sudo mount -o remount,suid /data

# start debian lxc
sudo lxc-start debian
