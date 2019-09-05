#!/bin/bash

set -eu

branch=$(git branch | grep \* | cut -d ' ' -f2 | sed -e 's@/@.@g')
CMAKE_BUILD_TYPE=${1:-Debug}

dir=_build.$branch.$CMAKE_BUILD_TYPE
mkdir "$dir" -p
cd "$dir"

cmake .. \
    -DSERIOUS_PROTON_DIR=$(pwd)/../../SeriousProton/ \
    -DSFML_ROOT=$(pwd)/../../SFML-2.5.1 \
    -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE

make -j8

echo "Build '$CMAKE_BUILD_TYPE' in '$dir', to run, execute:"
echo "    ./$dir/EmptyEpsilon"