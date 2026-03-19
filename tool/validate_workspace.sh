#!/usr/bin/env bash

set -euo pipefail

mode="${1:-}"

case "$mode" in
  min|max)
    ;;
  *)
    echo "Usage: tool/validate_workspace.sh <min|max>" >&2
    exit 64
    ;;
esac

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

dart --disable-analytics
dart --version

if [[ "$mode" == "min" ]]; then
  dart pub downgrade
else
  dart pub upgrade
fi

dart analyze copy_with_extension copy_with_extension_gen

rm -rf copy_with_extension_gen/.dart_tool/build
rm -rf copy_with_extension_gen/.dart_tool/build_entrypoint

pushd copy_with_extension_gen >/dev/null
dart run build_runner build --delete-conflicting-outputs
dart test --reporter github
popd >/dev/null
