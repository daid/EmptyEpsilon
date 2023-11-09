#!/bin/bash

set -euo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SERIOUS_PROTON_DIR="$DIR/../SeriousProton"
cd "$DIR"

# SeriousProton is a required dependency, as it is the game engine used by EmptyEpsilon
if [ ! -d "$SERIOUS_PROTON_DIR" ]; then
	echo "Please git clone https://github.com/daid/SeriousProton to '$SERIOUS_PROTON_DIR' to proceed."
	exit 1
fi

mkdir -p _build
cd _build

cmake .. -DSERIOUS_PROTON_DIR="$SERIOUS_PROTON_DIR" \
	-DCPACK_PACKAGE_VERSION_MAJOR=2023 \
	-DCPACK_PACKAGE_VERSION_MINOR=06 \
	-DCPACK_PACKAGE_VERSION_PATCH=12 \
	-DCMAKE_INSTALL_PREFIX=.
make

# Copy all the assets to the app bundle when building on MacOS
if [ "$(uname)" == "Darwin" ]; then
	make install
fi
