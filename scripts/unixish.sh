#!/usr/bin/env bash

set -euo pipefail

echo '::group::Prep'

# validate input and prepare some vars

_base_url='https://github.com/mikefarah/yq/releases/download'

_os=
_arch=

_root_name=
_dl_name=
_dl_path=
_dl_url=

case $RUNNER_OS in
  Linux)
    _os='linux'
    ;;
  macOS)
    _os='darwin'
    ;;

  *)
    echo "Cannot handle OS of type $RUNNER_OS"
    echo "Expected one of: [ Linux macOS ]"
    exit 1
    ;;
esac

case $RUNNER_ARCH in
  'X86')
    _arch='386'
    ;;
  'X64')
    _arch='amd64'
    ;;
  'ARM')
    _arch='arm'
    ;;
  'ARM64')
    _arch='arm64'
    ;;

  *)
    echo "Cannot handle arch of type $RUNNER_ARCH"
    echo "Expected one of: [ X86 X64 ARM ARM64 ]"
    exit 1
    ;;
esac

_root_name="yq_${_os}_${_arch}"

echo "Creating temporary directory $RUNNER_TEMP/${_root_name}"
mkdir -p "$RUNNER_TEMP/${_root_name}"

if [[ $DL_COMPRESSED == 'true' ]]; then
  _dl_name="${_root_name}.tar.gz"
  _dl_path="$RUNNER_TEMP/${_dl_name}"
else
  _dl_name="${_root_name}"
  _dl_path="$RUNNER_TEMP/${_root_name}/${_dl_name}"
fi

# default to _something_...
_version="${YQ_VERSION}"

if [ -z "${YQ_VERSION}" ]; then
  _version='v4.44.3'
fi

_dl_url="${_base_url}/${_version}/${_dl_name}"

echo '::endgroup::'

echo "::group::Downloading yq ${_version}"

echo "Src: ${_dl_url}"
echo "Dst: ${_dl_path}"

curl -L "${_dl_url}" -o "${_dl_path}"

echo '::endgroup::'

if [[ $DL_COMPRESSED == 'true' ]]; then
  echo '::group::Expanding archive'
  tar -xzv -C "$RUNNER_TEMP/${_root_name}" -f "${_dl_path}"
  echo "Removing ${_dl_path}"
  rm -rf "${_dl_path}"
  echo '::endgroup::'
fi

echo '::group::Copying to tool cache'

echo "Creating tool cache directory $RUNNER_TOOL_CACHE/yq"
mkdir -p "$RUNNER_TOOL_CACHE/yq"

echo "Installing into tool cache:"
echo "Src: $RUNNER_TEMP/${_root_name}/${_root_name}"
echo "Dst: $RUNNER_TOOL_CACHE/yq/yq"
mv "$RUNNER_TEMP/${_root_name}/${_root_name}" "$RUNNER_TOOL_CACHE/yq/yq"

echo "Removing $RUNNER_TEMP/${_root_name}"
rm -rf "$RUNNER_TEMP/${_root_name}"

echo "Adding $RUNNER_TOOL_CACHE/yq to path..."
echo "$RUNNER_TOOL_CACHE/yq" >> $GITHUB_PATH

echo '::endgroup::'
