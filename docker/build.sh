#!/usr/bin/env bash

# Abort at the first error.
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_DIR=$HOME/work/EmptyEpsilon
# For debugging.
echo "PROJECT_DIR set to {$PROJECT_DIR}"
echo "GITHUB_REF: ${GITHUB_REF}"
echo "GITHUB_HEAD_REF: ${GITHUB_HEAD_REF}"
echo "GITHUB_BASE_REF: ${GITHUB_BASE_REF}"

GIT_REF_NAME_LIST=( "${GITHUB_HEAD_REF}" "${GITHUB_BASE_REF}" "${GITHUB_REF}" "master" )
for git_ref_name in "${GIT_REF_NAME_LIST[@]}"
do
  if [ -z "${git_ref_name}" ]; then
    continue
  fi
  git_ref_name="$(basename "${git_ref_name}")"
  # Skip refs/pull/1234/merge as pull requests use it as GITHUB_REF
  if [[ "${git_ref_name}" == "merge" ]]; then
    echo "Skip [${git_ref_name}]"
    continue
  fi
  SERIOUS_PROTON_BRANCH="${git_ref_name}"
  output="$(git ls-remote --heads https://github.com/Daid/SeriousProton "${SERIOUS_PROTON_BRANCH}")"
  if [ -n "${output}" ]; then
    echo "Found SeriousProton branch [${SERIOUS_PROTON_BRANCH}]."
    break
  else
    echo "Could not find SeriousProton banch [${SERIOUS_PROTON_BRANCH}], try next."
  fi
done

echo "Using SeriousProton branch ${SERIOUS_PROTON_BRANCH} ..."

git clone --depth=1 -b "${SERIOUS_PROTON_BRANCH}" https://github.com/Daid/SeriousProton.git "${PROJECT_DIR}"/SeriousProton

if [[ $1 == 'win32' ]]; then
sudo ln -s /usr/i686-w64-mingw32/include/windows.h /usr/i686-w64-mingw32/include/Windows.h
# This is a workaround for a Discord SDK bug

mkdir -p _build_win32
cd _build_win32
cmake .. -G Ninja -DCMAKE_MAKE_PROGRAM=ninja -DCMAKE_TOOLCHAIN_FILE=../cmake/mingw.toolchain -DSERIOUS_PROTON_DIR=$PROJECT_DIR/SeriousProton/
ninja package

# Make EmptyEpsilon show up in a folder inside the ZIP
mkdir upload
cd upload
mv ../EmptyEpsilon.zip .
unzip -q EmptyEpsilon.zip
rm EmptyEpsilon.zip

elif [[ $1 == 'linux' ]]; then
mkdir build
cd build
cmake .. -DSERIOUS_PROTON_DIR=$PROJECT_DIR/SeriousProton/
make
cmake --build . --target package 
# "make package" could also be used instead of the "cmake --build" command.

elif [[ $1 == 'macos' ]]; then
cd $PROJECT_DIR/EmptyEpsilon
mkdir _build
cd _build
cmake .. -DSERIOUS_PROTON_DIR=$PROJECT_DIR/SeriousProton/
make && make install

cd $PROJECT_DIR
git clone https://github.com/auriamg/macdylibbundler.git
cd macdylibbundler
make && make install
dylibbundler --overwrite-dir --bundle-deps --search-path "/usr/local/lib" --fix-file "$PROJECT_DIR/EmptyEpsilon/_build/EmptyEpsilon.app/Contents/MacOS/EmptyEpsilon" --dest-dir "$PROJECT_DIR/EmptyEpsilon/_build/EmptyEpsilon.app/Contents/libs"

cd $PROJECT_DIR/EmptyEpsilon/_build
mkdir ../_staging
cp -r EmptyEpsilon.app script_reference.html ../_staging
mkdir ../tmp
hdiutil create "../tmp/tmp.dmg" -ov -volname "EmptyEpsilon" -fs HFS+ -srcfolder "../_staging"
hdiutil convert "../tmp/tmp.dmg" -format UDZO -o "EmptyEpsilon.dmg"

elif [[ $1 == 'android' ]]; then

# If the key file does not exist, make a new one. The GH Actions should have put the keyfile there by now.
if [ ! -r $HOME/.keystore ]; then
keytool -noprompt -genkey -alias Android -keyalg RSA -keysize 2048 -validity 10000 -storepass password -keypass password -dname "CN=daid.github.io, OU=EmptyEpsilon, O=EmptyEpsilon, L=None, ST=None, C=None"
echo "Key not found! Generating a new key!"
fi

mkdir _build_android
cd _build_android
cmake .. -DCMAKE_TOOLCHAIN_FILE=$PROJECT_DIR/EmptyEpsilon/cmake/android.toolchain -DSERIOUS_PROTON_DIR=$PROJECT_DIR/SeriousProton -DCMAKE_MAKE_PROGRAM=$(which make)
make -j 5

else
echo "Error! No valid args passed!"
exit 1 
fi
