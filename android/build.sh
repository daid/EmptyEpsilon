#!/bin/sh

export PATH=$PATH:$HOME/android/android-sdk-linux/tools:$HOME/android/android-sdk-linux/platform-tools:$HOME/android/android-ndk-r10e

set -e
rm -rf assets/*
cp ../resources assets/ -a
cp ../scripts assets/ -a

#remove all music to save space
rm -rf assets/resources/music

android update project --name EmptyEpsilon --target "android-16" --path .
ndk-build -j 2
ant debug


adb install -r ./bin/EmptyEpsilon-debug.apk
adb shell am start -n eu.daid.emptyepsilon/android.app.NativeActivity
