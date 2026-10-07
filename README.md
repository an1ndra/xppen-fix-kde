# xppen-fix-kde

Make **XP-Pen / UC-Logic drawing tablets work natively on Linux** (KDE Plasma
Wayland, GNOME Wayland, etc.) — with **pressure, tilt, pen buttons and eraser** —
by loading the in-kernel **`hid_uclogic`** driver.

No OpenTabletDriver. No vendor userspace driver. Just the kernel driver the
tablet already has.

---

## The problem

Many XP-Pen (and UGEE / Huion / Artisul / VEIKK) tablets are supported by the
kernel module **`hid_uclogic`**. But some setups never load it:

* the **XP-Pen vendor driver** (`xppenlinux`) is **X11-only**, and
* **OpenTabletDriver blacklists `hid_uclogic`** (its own docs tell you to
  blacklist `wacom` and `hid_uclogic`).

When `hid_uclogic` isn't loaded, the tablet falls back to `hid-generic`, which
**does not decode the pen reports**. Symptoms:

* the cursor doesn't move (or only appears on tip-touch),
* **no pressure** under a Wayland session,
* the tablet is missing from *System Settings → Drawing Tablet*,
* people then install OTD, which fights KWin's tablet handling.

## The fix

Load `hid_uclogic` and make sure nothing blacklists it. The tablet then appears
as a **real** graphics tablet:

```
tablet → hid_uclogic (kernel) → libinput → KWin/compositor → app (pressure)
```

Verified on an **XP-Pen Deco 01 V2** (`28bd:0905`) with **KDE Plasma 6 (Wayland)**:
cursor tracking, pressure, tilt, hover, pen buttons and eraser all work.

## Install

### Debian / Ubuntu / KDE neon
Grab the `.deb` from the [Releases](../../releases) page (or build it, below):

```sh
sudo apt install ./xppen-uclogic_*.deb
```

### Any other systemd distro
```sh
sudo ./install-generic.sh
```

### What it installs
| Path | Purpose |
|---|---|
| `/etc/modules-load.d/hid-uclogic.conf` | load `hid_uclogic` at boot |
| `/etc/modprobe.d/zzz-hid-uclogic.conf` | force-load it even if blacklisted |

The package's `postinst` also removes any `blacklist hid_uclogic` line, loads
the module immediately and nudges udev.

> This package **Conflicts** with `xppenlinux` (X11-only vendor driver) and
> `opentabletdriver` (which blacklists `hid_uclogic`) on purpose.

## Verify

```sh
lsmod | grep hid_uclogic
grep -H "PenTablet Pen" /proc/bus/input/devices
```

You should see a `UGTABLET ... PenTablet Pen` device. Then check
*System Settings → Drawing Tablet*.

## Build the .deb locally

```sh
./build-deb.sh          # -> dist/xppen-uclogic_<version>_all.deb
```

## Create a release with a .deb (GitHub Actions)

The workflow in [`.github/workflows/build-deb.yml`](.github/workflows/build-deb.yml)
builds the `.deb` on every push, and attaches it to a **GitHub Release** when you
push a tag:

```sh
git tag v1.0
git push origin v1.0
```

You can also run it manually from the **Actions** tab (Artifacts → the `.deb`).

## Notes / troubleshooting

* The kernel module must exist: `modinfo hid_uclogic`.
  On Ubuntu it ships in `linux-modules-extra-$(uname -r)`.
* Plug the tablet into a **direct USB port**, not a cheap hub — unstable hubs
  cause `error -32` disconnects that look like a driver problem.
* Removing the package leaves `hid_uclogic` loaded on purpose (unloading would
  break the tablet until the next replug).

## License

MIT — see [LICENSE](LICENSE).
