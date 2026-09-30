# demo-bazel

A Bazel monorepo on PipeMesh: five services, three shared libraries, and
a dispatch pipeline that sends each revision only to the services the
change can affect.

```
libs/money   ─┬─ orders    payments   catalog
libs/events  ─┼─ orders    inventory  notifications
libs/http    ─┴─ every service
```

- `pipemesh.yaml` — the dispatch pipeline: a `graph` job fingerprints
  every service with the `bazel/fingerprint@1` component (bazel-diff's
  target hashes: a fingerprint changes exactly when a change can change
  the service), and one `delegate: pipeline` job per service consumes
  its fingerprint and dispatches when it changed (`sources: []`: the
  entry is its only input).
- `.pipemesh/service.yaml` — each service's own pipeline: build + test
  with Bazel, then staging and production, which deploy only a jar that
  is new to them, or a changed deploy script (`sources: [deploy/**]`).
- `tools/affected.sh <base> [<head>]` — the services a diff affects
  (`rdeps` of the touched packages); pull request checks test only those.

Try it: change `libs/money` and only orders, payments and catalog
receive the revision; change a README or a `MODULE.bazel` comment and
nothing does.

Each service pipeline lives under the dispatch pipeline on PipeMesh:
`/github.com/pipemesh/demo-bazel/-/pipeline/<service>`.

The dispatch pipeline reads Bazel, not paths: see the `bazel/fingerprint`
component in [pipemesh/components](https://github.com/pipemesh/components/blob/main/bazel/fingerprint.yaml).
