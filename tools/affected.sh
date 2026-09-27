#!/usr/bin/env bash
# Prints the deployable services a range of commits affects, one per
# line: every target tagged "deployable" that depends, transitively, on
# a package the diff touched.
#
#   tools/affected.sh <base> [<head>]
#
# Package-granular rdeps, the classic query. Changes Bazel can't place
# in a package (MODULE.bazel, .bazelrc, .bazelversion, tools/) print
# every service: they can change any output. Hash-based tools
# (bazel-diff, target-determinator) narrow those cases too.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
base=$1; head=${2:-HEAD}
bazel=tools/bazelw

all() { $bazel query --noshow_progress 'attr(tags, "\bdeployable\b", //...)' 2>/dev/null; }
name() { sed -E 's#^//services/([^:]+):.*#\1#'; }

pkgs=()
while IFS= read -r f; do
  case "$f" in
    MODULE.bazel|MODULE.bazel.lock|.bazelrc|.bazelversion|tools/*) all | name; exit ;;
  esac
  # The nearest directory with a BUILD file owns the path (a deleted
  # file still has its package).
  d=$(dirname "$f")
  while [ "$d" != "." ] && [ ! -f "$d/BUILD.bazel" ] && [ ! -f "$d/BUILD" ]; do d=$(dirname "$d"); done
  [ "$d" != "." ] && pkgs+=("//$d:*")
done < <(git diff --name-only "$base" "$head")

[ ${#pkgs[@]} -eq 0 ] && exit 0
$bazel query --noshow_progress --keep_going \
  "attr(tags, \"\\bdeployable\\b\", rdeps(//..., set(${pkgs[*]})))" 2>/dev/null | name | sort -u
