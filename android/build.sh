#!/bin/sh

export PATH=$PATH:$HOME/android/android-sdk-linux/tools:$HOME/android/android-sdk-linux/platform-tools:$HOME/android/android-ndk-r10e

set -e
rm -rf assets/*
cp ../resources assets/ -a
cp ../scripts assets/ -a

#remove all music to save space
rm -rf assets/resources/music

android update project --name EmptyEpsilon --target "android-10" --path .
ndk-build -j 2

# Check if we have a key generated with: keytool -genkey -v -keystore $HOME/android_ee_key.keystore -alias alias_name -keyalg RSA -keysize 2048 -validity 10000
if [ -f "$HOME/android_ee_key.keystore" ]; then
    ant release
    jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore $HOME/android_ee_key.keystore ./bin/EmptyEpsilon-release-unsigned.apk EmptyEpsilon
    zipalign -v 4 ./bin/EmptyEpsilon-release-unsigned.apk ./bin/EmptyEpsilon-release.apk
else
    ant debug
fi

if [ -f "do_install" ]; then
    adb install -r ./bin/EmptyEpsilon-debug.apk
    adb shell am start -n eu.daid.emptyepsilon/android.app.NativeActivity
fi
