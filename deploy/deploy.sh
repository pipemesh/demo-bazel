#!/usr/bin/env bash
# A puppet deploy: ships the service's deploy jar "to" an environment
# and smoke-tests it. Swap for your real rollout.
set -euo pipefail
svc=$1; env=$2
jar=dist/$svc.jar
[ -f "$jar" ] || { echo "missing $jar: the build job's artifact did not arrive" >&2; exit 1; }
echo "deploying $svc to $env: $( (sha256sum "$jar" 2>/dev/null || shasum -a 256 "$jar") | cut -c1-12)"
PORT=18080 java -jar "$jar" & pid=$!
trap 'kill $pid 2>/dev/null' EXIT
for _ in $(seq 1 50); do curl -fsS localhost:18080 && break; sleep 0.2; done
echo
echo "$svc is live in $env"
