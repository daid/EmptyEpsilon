#!/usr/bin/env bash

# Abort at the first error.
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_DIR="$( cd "${SCRIPT_DIR}/.." && pwd )"

# For debugging.
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

mkdir build
cd build
cmake .. -DSERIOUS_PROTON_DIR=$PROJECT_DIR/SeriousProton/
make

