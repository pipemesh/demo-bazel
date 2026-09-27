# demo-bazel

A Bazel monorepo on PipeMesh: five services, three shared libraries, and
a dispatch pipeline that sends each revision only to the services the
change can affect.

```
libs/money   ─┬─ orders    payments   catalog
libs/events  ─┼─ orders    inventory  notifications
libs/http    ─┴─ every service
```

- `pipemesh.yaml` — the dispatch pipeline: one `delegate: pipeline` job
  per service, gated by `changes:` on the service's dependency closure.
- `.pipemesh/service.yaml` — each service's own pipeline: build + test
  with Bazel, then staging and production.
- `tools/gen-rules.sh` — writes `.pipemesh/affected.yaml` from
  `bazel query deps(...)`; `--check` fails when it is stale, and the
  dispatch pipeline runs it before anything is dispatched.
- `tools/affected.sh <base> [<head>]` — the services a diff affects
  (`rdeps` of the touched packages); pull request checks test only those.

Try it: change `libs/money` and only orders, payments and catalog
receive the revision; change a README and nothing does.

Each service pipeline lives under the dispatch pipeline on PipeMesh:
`/github.com/pipemesh/demo-bazel/-/pipeline/<service>`.
