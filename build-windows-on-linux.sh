#!/bin/bash

set -euo pipefail

# See https://github.com/daid/EmptyEpsilon/wiki/Build%5CWindows-on-Linux for required dependencies

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SERIOUS_PROTON_DIR="$DIR/../SeriousProton"
cd "$DIR"

# SeriousProton is a required dependency, as it is the game engine used by EmptyEpsilon
if [ ! -d "$SERIOUS_PROTON_DIR" ]; then
        echo "Please git clone https://github.com/daid/SeriousProton to '$SERIOUS_PROTON_DIR' to proceed."
        exit 1
fi

mkdir -p _build_win32
cd _build_win32

cmake .. -G Ninja \
        -DCMAKE_MAKE_PROGRAM=ninja \
        -DCMAKE_TOOLCHAIN_FILE=../cmake/mingw.toolchain \
        -DSERIOUS_PROTON_DIR="$SERIOUS_PROTON_DIR" \
        -DCPACK_PACKAGE_VERSION_MAJOR=2023 \
        -DCPACK_PACKAGE_VERSION_MINOR=06 \
        -DCPACK_PACKAGE_VERSION_PATCH=12 \
        -DCMAKE_INSTALL_PREFIX=.
ninja package
