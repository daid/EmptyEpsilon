#!/bin/bash

mkdir -p _build
cd _build
cmake .. -DSERIOUS_PROTON_DIR=$PWD/../../SeriousProton/ \
	-DCPACK_PACKAGE_VERSION_MAJOR=2019 \
	-DCPACK_PACKAGE_VERSION_MINOR=05 \
	-DCPACK_PACKAGE_VERSION_PATCH=21
make
