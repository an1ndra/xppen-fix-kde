#!/bin/sh
# Portable installer for XP-Pen / UC-Logic tablets via the kernel hid_uclogic
# driver, for non-Debian systems (systemd). For Debian/Ubuntu/KDE neon use the
# .deb instead.
#
# It: loads hid_uclogic at boot, removes any blacklist entry, and loads it now.
set -e

[ "$(id -u)" = 0 ] || { echo "Please run as root (sudo $0)"; exit 1; }

MP="$(command -v modprobe || echo /sbin/modprobe)"

# 1) load at boot
echo hid_uclogic > /etc/modules-load.d/hid-uclogic.conf

# 2) force explicit loading even if blacklisted
mkdir -p /etc/modprobe.d
printf '# xppen-uclogic: force-load hid_uclogic\ninstall hid_uclogic %s --ignore-install hid_uclogic\n' "$MP" \
    > /etc/modprobe.d/zzz-hid-uclogic.conf

# 3) remove blacklist entries
for f in /etc/modprobe.d/*.conf /usr/lib/modprobe.d/*.conf /lib/modprobe.d/*.conf; do
    [ -f "$f" ] || continue
    sed -i -E 's|^([[:space:]]*blacklist[[:space:]]+hid_uclogic.*)$|# disabled by xppen-uclogic: \1|' "$f" 2>/dev/null || true
done

# 4) load now + nudge udev
modprobe hid_uclogic 2>/dev/null || true
command -v udevadm >/dev/null 2>&1 && {
    udevadm control --reload-rules 2>/dev/null || true
    udevadm trigger --action=add --subsystem-match=hid 2>/dev/null || true
}

if lsmod | grep -q '^hid_uclogic'; then
    echo "OK: hid_uclogic loaded. Your tablet should work (check System Settings > Drawing Tablet)."
else
    echo "WARNING: hid_uclogic did not load. Is the hid-uclogic module available? (modinfo hid_uclogic)" >&2
fi
