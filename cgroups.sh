if ! mountpoint -q /sys/fs/cgroup 2>/dev/null >/dev/null; then
  mkdir -p /sys/fs/cgroup
  mount -t tmpfs -o rw,nosuid,nodev,noexec,relatime cgroup_root /sys/fs/cgroup
fi

for cg in blkio cpu cpuacct cpuset devices freezer memory pids; do
  if ! mountpoint -q "/sys/fs/cgroup/${cg}" 2>/dev/null >/dev/null; then
    mkdir -p "/sys/fs/cgroup/${cg}"
    mount -t cgroup -o "rw,nosuid,nodev,noexec,relatime,${cg}" "${cg}" "/sys/fs/cgroup/${cg}" \
      2>/dev/null >/dev/null
  fi
done

mkdir -p /sys/fs/cgroup/systemd
mount -t cgroup -o none,name=systemd systemd /sys/fs/cgroup/systemd 2>/dev/null >/dev/null

umount -Rl /sys/fs/cgroup/cg2_bpf 2>/dev/null >/dev/null
umount -Rl /sys/fs/cgroup/schedtune 2>/dev/null >/dev/null
