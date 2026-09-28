#!/usr/bin/env bash
# Writes one file per deployable service into $1 (default: fingerprints/):
# a digest of the bazel-diff hash of every target in the service's
# package. A bazel-diff hash covers the target's sources, its rule and its
# whole dependency graph, external repositories included — so a service's
# file changes exactly when a change can change what the service builds
# or tests, and a README, a sibling's code or an unrelated dependency
# bump leave it alone.
#
# Every service's file also covers what its pipeline runs outside Bazel
# (the service pipeline's config and the deploy scripts), so a change to
# how services ship reaches them too.
#
# The dispatch pipeline produces these files as entries and dispatches a
# service when its entry changed since that service's last dispatch.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
out=${1:-fingerprints}

version=v49.1.0
case "$(uname -s)-$(uname -m)" in
  Linux-x86_64)  asset=bazel-diff-rust-linux-amd64
                 sum=ab9dea07341a4d764aaed15225ac5ea65f381fc1a1ae304e9fc0147b5e832a87 ;;
  Linux-aarch64) asset=bazel-diff-rust-linux-arm64
                 sum=3c528f28c079f5889728613771ea5f679c26ec67a12acecac345322dcb13c4af ;;
  Darwin-arm64)  asset=bazel-diff-rust-macos-arm64
                 sum=1a0ca31c4bf28f8ad14a8fde17d9380f0513f8f386ba20f8d05e441aa12438f5 ;;
  *) echo "no bazel-diff build for $(uname -s)-$(uname -m)" >&2; exit 1 ;;
esac
sha256() { if command -v sha256sum >/dev/null; then sha256sum | cut -d' ' -f1; else shasum -a 256 | cut -d' ' -f1; fi; }
# The CI image carries bazel-diff at $BAZEL_DIFF; elsewhere it is fetched once.
bin="${BAZEL_DIFF:-${XDG_CACHE_HOME:-$HOME/.cache}/bazel-diff-$version-$asset}"
if [ ! -x "$bin" ]; then
  mkdir -p "$(dirname "$bin")"
  curl -fsSL -o "$bin.tmp" "https://github.com/Tinder/bazel-diff/releases/download/$version/$asset"
  [ "$(sha256 < "$bin.tmp")" = "$sum" ] || { echo "bazel-diff download does not match its pinned sha256" >&2; exit 1; }
  chmod +x "$bin.tmp" && mv "$bin.tmp" "$bin"
fi

hashes=$(mktemp)
trap 'rm -f "$hashes"' EXIT
"$bin" generate-hashes -w "$PWD" -b "$PWD/tools/bazelw" "$hashes" >&2

# The files every service pipeline runs besides its Bazel targets.
shipping=$(git ls-files -s -- .pipemesh/service.yaml deploy | sha256)

rm -rf "$out" && mkdir -p "$out"
for t in $(tools/bazelw query --noshow_progress 'attr(tags, "\bdeployable\b", //...)' 2>/dev/null); do
  pkg=${t%%:*}
  svc=${pkg##*/}
  { grep -o "\"$pkg:[^\"]*\":\"[^\"]*\"" "$hashes" | sort; echo "shipping $shipping"; } | sha256 > "$out/$svc"
  echo "$svc $(cut -c1-12 "$out/$svc")"
done
