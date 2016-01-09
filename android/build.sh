#!/bin/sh

export PATH=$PATH:$HOME/android/android-sdk-linux/tools:$HOME/android/android-sdk-linux/platform-tools:$HOME/android/android-ndk-r10e

set -e
rm -rf assets/*
cp ../resources assets/ -a
cp ../scripts assets/ -a

#remove all music and 3d models to save space
rm -rf assets/resources/music
rm -rf assets/resources/*.obj
rm -rf assets/resources/ammo_box*
rm -rf assets/resources/*_texture*
rm -rf assets/resources/fire_ring.png
rm -rf assets/resources/shield_hit_effect.png

android update project --name EmptyEpsilon --target "android-16" --path .
ndk-build -j 2 -B

# Check if we have a key generated with: keytool -genkey -v -keystore $HOME/android_ee_key.keystore -alias EmptyEpsilon -keyalg RSA -keysize 2048 -validity 10000
if [ -f "$HOME/android_ee_key.keystore" ]; then
    ant release
    jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore $HOME/android_ee_key.keystore ./bin/EmptyEpsilon-release-unsigned.apk EmptyEpsilon
    zipalign -f -v 4 ./bin/EmptyEpsilon-release-unsigned.apk ./bin/EmptyEpsilon-release.apk
else
    ant debug
fi

if [ -f "do_install" ]; then
    adb install -r ./bin/EmptyEpsilon-debug.apk
    adb shell am start -n eu.daid.emptyepsilon/android.app.NativeActivity
fi
