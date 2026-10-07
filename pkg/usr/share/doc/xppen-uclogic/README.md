# xppen-uclogic

Enable the **in-kernel `hid_uclogic` driver** for XP-Pen / UC-Logic drawing
tablets (XP-Pen, UGEE, Huion, Artisul, VEIKK, ...) on Debian/Ubuntu/KDE neon.

## Problem

Many XP-Pen tablets are supported by the kernel module `hid_uclogic`, but:

* the XP-Pen vendor driver (`xppenlinux`) is **X11-only**, and
* **OpenTabletDriver blacklists `hid_uclogic`**.

When `hid_uclogic` is not loaded, the tablet is handled by the generic
`hid-generic` driver, which does **not** decode the pen reports. The result:

* the cursor does not move (or only on tip-touch),
* there is **no pressure** under a Wayland session,
* custom user-space drivers (OTD) then fight KWin's tablet handling.

## Fix

This package loads `hid_uclogic` (at boot and immediately) and removes any
`blacklist hid_uclogic` entry. The tablet then appears as a **real** graphics
tablet:

```
tablet → hid_uclogic (kernel) → libinput → KWin/compositor → app (pressure)
```

It shows up in **System Settings → Drawing Tablet**, with working pressure,
tilt, pen buttons and eraser on KDE Plasma 6 Wayland.

## Install / remove

```sh
sudo apt install ./xppen-uclogic_1.0_all.deb
# or
sudo dpkg -i xppen-uclogic_1.0_all.deb
sudo apt-get -f install

sudo apt remove xppen-uclogic   # note: leaves hid_uclogic loaded on purpose
```

## Verify

```sh
lsmod | grep hid_uclogic
grep -H "PenTablet Pen" /proc/bus/input/devices
```

You should see a `UGTABLET ... PenTablet Pen` input device.

## Notes

* If it does not work, make sure the `hid-uclogic` kernel module actually
  exists: `modinfo hid_uclogic`. On Ubuntu it ships in `linux-modules-extra-$(uname -r)`.
* Plug the tablet into a **direct USB port** (not a cheap hub) for a stable
  connection.
* This package **Conflicts** with `xppenlinux` and `opentabletdriver` on purpose.
