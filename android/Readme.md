Building for Android depends on the cmake toolchain file in `cmake/android.toolchain`, and having `cmake` and [Oracle Java 8 or newer JRE and JDK packages](https://www.oracle.com/java/technologies/downloads/) for your OS installed. (OpenJDK does NOT work for building!)

In addition configuring the EE build, this toolchain file does a few additional things:

-   Downloads and installs the android SDK + NDK with all required tools. This requires accepting a license.
-   Downloads and compiles SDL2 with requirements and installs those in the NDK folder.
-   Builds an APK from the compiled sources.

## Build for 32-bit ARM v7

Building 32-bit EE for Android should be as easy as running from the repo root:

```
mkdir _build_android
cd _build_android
cmake .. -G Ninja -DSERIOUS_PROTON_DIR=../../SeriousProton -DCMAKE_TOOLCHAIN_FILE=../cmake/android.toolchain
ninja
```

## Build for 64-bit ARM v8

Some newer devices, such as the Pixel 7 series, won't run 32-bit Android apps.

To build 64-bit EE for Android, add the `-DANDROID_ABI=arm64-v8a` flag:

```
mkdir _build_android_64
cd _build_android_64
cmake .. -G Ninja -DSERIOUS_PROTON_DIR=../../SeriousProton -DCMAKE_TOOLCHAIN_FILE=../cmake/android.toolchain -DANDROID_ABI=arm64-v8a
ninja
```

## Troubleshooting

### "CMAKE_MAKE_PROGRAM is not set"

If you encounter a `CMAKE_MAKE_PROGRAM is not set` error, make sure you've installed `make`. If you've installed it, ensure it's in your `$PATH`/`%PATH%`; if it is and it still fails, add `-DCMAKE_MAKE_PROGRAM=$(which make)` to manually specify its location.

### "jarsigner error"

If you encounter a `jarsigner error: java.lang.RuntimeException: keystore load: ... (No such file or directory)` error, you need to create a keystore. The Android build script uses:

```
keytool -genkey -alias ${ANDROID_SIGN_KEY_NAME} -keyalg RSA -keysize 2048 -validity 10000
```

where the default `ANDROID_SIGN_KEY_NAME` is `"Android"` and the default password is `password`, and the command generates the keystore file at `~/.keystore`.

### "Invalid keystore format"

If you have a keystore but get a `keystore load: Invalid keystore format` error, ensure that the keystore conforms to the above command's flags and is at the specified location. See `cmake/android.toolchain` for details.

Note that this only works on Linux. Building for Android from Windows is not supported at the moment.
