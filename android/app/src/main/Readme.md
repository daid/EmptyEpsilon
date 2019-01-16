Building the Android version is a bit of a hassle right now.

First, you need the following things:
* Android SDK
* Android NDK
* SFML-2.3.1 sources
* EmptyEpsilon sources
* SeriousProton sources

Next, you need to patch SFML-2.3.1 it to prevent a crash bug:
See: http://en.sfml-dev.org/forums/index.php?topic=18581.0


Finally, you need to build SFML for android.
This guide explains it:
https://github.com/SFML/SFML/wiki/Tutorial:-Building-SFML-for-Android

For reference. I've used linux. Installed the android NDK and SDK in $HOME/android
I've build SFML-2.3.1 with the following commands:
```
export PATH=$PATH:$HOME/android/android-sdk-linux/tools:$HOME/android/android-sdk-linux/platform-tools:$HOME/android/android-ndk-r10e
export ANDROID_NDK=$HOME/android/android-ndk-r10e
mkdir build_armeabi-v7a
cd build_armeabi-v7a
cmake -DANDROID_ABI=armeabi-v7a -DCMAKE_TOOLCHAIN_FILE=../cmake/toolchains/android.toolchain.cmake ..
make -j 3
make install
```

To test this, I highly recommend building the SFML android example to see if it works.
```
cd SFML-2.3.1/examples/android
android update project --name Example --target "android-16" --path .
ndk-build
ant debug
```
And install the resulting bin/Example-debug.apk to your device to test it.
(uninstall it afterwards, as it has the tendency to keep running and drain your battery)


Finally, build EmptyEpsilon:
```
cd EmptyEpsilon/android
android update project --name EmptyEpsilon --target "android-16" --path .
ndk-build
and debug
```
