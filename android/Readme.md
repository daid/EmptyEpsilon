Building for android depends on the cmake toolchain file in cmake/android.toolchain

This toolchain file does a few things next to being just a toolchain file:
* It downloads and install the android SDK + NDK with all required tools. This requires accepting a license
* It downloads and compiles SFML with requirements and installs those in the NDK folder
* Builds an APK from the compiled sources

Because of this, building EE for android should be as easy as:
```
mkdir _build_android
cd _build_android
cmake .. -DCMAKE_TOOLCHAIN_FILE=../cmake/android.toolchain -DSERIOUS_PROTON_DIR=../../SeriousProton
make -j 5
```
Note that this only works on linux. Building from windows is not supported at the moment.
