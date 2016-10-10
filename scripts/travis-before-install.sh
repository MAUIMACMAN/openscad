#!/bin/bash

set -x

DIST="$1"

#
# Simple way for testing, e.g. replace command calls with echo
# SUDO=echo WGET=echo ./scripts/travis-before-install.sh trusty
#
SUDO=${SUDO:-sudo}
WGET=${WGET:-wget}

QUIET="-qq"

echo "DIST = $DIST / Running on:"
echo
cat /etc/os-release
echo

"$WGET" -qO - http://files.openscad.org/OBS-Repository-Key.pub | "$SUDO" apt-key add -

PACKAGES='
	build-essential
	libqt4-dev
	libqt4-opengl-dev
	libxmu-dev
	cmake
	bison
	flex
	git-core
	libboost-all-dev
	libXi-dev
	libmpfr-dev
	libboost-dev
	libglew-dev
	libeigen3-dev
	libcgal-dev
	libgmp3-dev
	libgmp-dev
	curl
	imagemagick
	libfontconfig-dev
	libopencsg-dev
'

# Purge fglrx driver if that is installed by default
# as this contains a libGL that breaks the GLX extension
# in Xvfb causing all graphical tests to fail.
"$SUDO" apt-get update "$QUIET"
"$SUDO" apt-get purge "$QUIET" fglrx

if [[ "$DIST" == "trusty" ]]
then

	echo "Adding external repositories for $DIST"
	echo 'yes' | "$SUDO" add-apt-repository 'deb http://download.opensuse.org/repositories/home:/t-paul:/lib3mf/xUbuntu_14.04/ ./'

	"$SUDO" apt-get update "$QUIET"
	"$SUDO" apt-get install "$QUIET" $PACKAGES libharfbuzz-dev lib3mf-dev

elif [[ "$DIST" == "precise" ]]
then

	echo 'yes' | "$SUDO" add-apt-repository ppa:chrysn/openscad
	echo 'yes' | "$SUDO" add-apt-repository 'deb http://download.opensuse.org/repositories/home:/t-paul:/lib3mf/xUbuntu_12.04/ ./'
	"$SUDO" apt-get update "$QUIET"
	"$SUDO" apt-get install "$QUIET" $PACKAGES lib3mf-dev

	echo 'yes' | "$SUDO" add-apt-repository ppa:mapnik/nightly-trunk
	"$SUDO" apt-get update "$QUIET"
	"$SUDO" apt-get install "$QUIET" libharfbuzz-dev

	echo 'yes' | "$SUDO" add-apt-repository ppa:oibaf/graphics-drivers
	"$SUDO" apt-get update "$QUIET"
	"$SUDO" apt-get install "$QUIET" --install-recommends libgl1-mesa-dev-lts-quantal

else

	echo "WARNING: No install recipe for distribution '$DIST'"

fi
