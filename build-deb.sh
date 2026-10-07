#!/bin/sh
# Build the xppen-uclogic .deb locally into ./dist
# Requires: dpkg-deb (from the 'dpkg' package)
set -e

cd "$(dirname "$0")"

VERSION="$(awk -F': ' '/^Version:/{print $2}' pkg/DEBIAN/control)"
OUT="xppen-uclogic_${VERSION}_all.deb"

chmod 0755 pkg/DEBIAN/postinst pkg/DEBIAN/prerm pkg/DEBIAN/postrm
mkdir -p dist
rm -f "dist/$OUT"

dpkg-deb --build --root-owner-group pkg "dist/$OUT"

echo
echo "Built: dist/$OUT"
sha256sum "dist/$OUT"
