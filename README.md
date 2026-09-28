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
  every service, and one `delegate: pipeline` job per service consumes
  its fingerprint and dispatches when it changed (`consumed: changed`).
- `.pipemesh/service.yaml` — each service's own pipeline: build + test
  with Bazel, then staging and production, which deploy only a jar that
  is new to them (`consumed: changed` again).
- `tools/fingerprint.sh` — one file per service from bazel-diff's target
  hashes: it changes exactly when a change can change the service.
- `tools/affected.sh <base> [<head>]` — the services a diff affects
  (`rdeps` of the touched packages); pull request checks test only those.

Try it: change `libs/money` and only orders, payments and catalog
receive the revision; change a README or a `MODULE.bazel` comment and
nothing does.

Each service pipeline lives under the dispatch pipeline on PipeMesh:
`/github.com/pipemesh/demo-bazel/-/pipeline/<service>`.

The dispatch pipeline reads Bazel, not paths: see `tools/fingerprint.sh`.
