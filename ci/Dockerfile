# The image demo-bazel's CI builds in: a C++ toolchain (Bazel's Java
# launcher needs one), bazelisk, bazel-diff, and the Bazel release named by
# ci/.bazelversion, installed and extracted. Tools only: this directory is
# the whole build context, so the image is exactly what is in it, and
# PipeMesh rebuilds it when (and only when) something here changes
# (build_ci in pipemesh.yaml). Keep ci/.bazelversion in step with
# /.bazelversion; a mismatch only makes jobs download the other release.
FROM debian:bookworm-slim@sha256:3783cc01769c7b2b1b83a5c5ad96c815348e28ed7da68e2e3687004faa906251
ARG TARGETARCH

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      bash ca-certificates curl git tar gzip unzip zip gcc g++ python3 \
 && rm -rf /var/lib/apt/lists/*

# bazelisk: runs the Bazel release .bazelversion names (tools/bazelw uses it).
RUN set -eu; \
    case "$TARGETARCH" in \
      amd64) sum=e1508323f347ad1465a887bc5d2bfb91cffc232d11e8e997b623227c6b32fb76 ;; \
      arm64) sum=bb608519a440d45d10304eb684a73a2b6bb7699c5b0e5434361661b25f113a5d ;; \
      *) echo "no bazelisk for $TARGETARCH" >&2; exit 1 ;; \
    esac; \
    curl -fsSL -o /usr/local/bin/bazelisk \
      "https://github.com/bazelbuild/bazelisk/releases/download/v1.27.0/bazelisk-linux-$TARGETARCH"; \
    echo "$sum  /usr/local/bin/bazelisk" | sha256sum -c -; \
    chmod +x /usr/local/bin/bazelisk

# bazel-diff: the graph job's target hashes (the bazel/fingerprint component).
RUN set -eu; \
    case "$TARGETARCH" in \
      amd64) sum=ab9dea07341a4d764aaed15225ac5ea65f381fc1a1ae304e9fc0147b5e832a87 ;; \
      arm64) sum=3c528f28c079f5889728613771ea5f679c26ec67a12acecac345322dcb13c4af ;; \
    esac; \
    curl -fsSL -o /usr/local/bin/bazel-diff \
      "https://github.com/Tinder/bazel-diff/releases/download/v49.1.0/bazel-diff-rust-linux-$TARGETARCH"; \
    echo "$sum  /usr/local/bin/bazel-diff" | sha256sum -c -; \
    chmod +x /usr/local/bin/bazel-diff

ENV BAZELISK_HOME=/opt/bazelisk BAZEL_DIFF=/usr/local/bin/bazel-diff

# Every bazel command starts from Bazel's installation, already extracted.
# External repositories are not in the image: they download into the
# repository cache inside the workspace (a relative path is the
# workspace's), which the jobs keep in a PipeMesh
# cache keyed on MODULE.bazel.lock; their unpacked contents stay outside it
# (Bazel refuses a repo contents cache inside the main repository).
RUN printf '%s\n' \
      'startup --install_base=/opt/bazel/install' \
      'common --repository_cache=.cache/bazel-repo' \
      'common --repo_contents_cache=/tmp/bazel-repo-contents' \
    > /etc/bazel.bazelrc
COPY .bazelversion /opt/bazel/.bazelversion
RUN cd /opt/bazel && USE_BAZEL_VERSION="$(cat .bazelversion)" bazelisk version \
 && USE_BAZEL_VERSION="$(cat .bazelversion)" bazelisk shutdown || true
