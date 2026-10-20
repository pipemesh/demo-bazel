#!/usr/bin/env python3
"""Writes a service's Bazel test results as a Markdown report.

Reads every test.xml and test.log Bazel left under bazel-testlogs for
services/<service> (a result Bazel took from the cache has them too) and
prints a verdict, one row per test target and each target's log. The
service pipeline's build job shows it in the Reports tab (reports:).

Usage: tools/test-report.py <service> > reports/tests.md
"""
import pathlib
import sys
import xml.etree.ElementTree as ET

service = sys.argv[1]
root = pathlib.Path("bazel-testlogs") / "services" / service
rows = []
for xml in sorted(root.rglob("test.xml")) if root.exists() else []:
    pkg, _, name = str(xml.parent.relative_to("bazel-testlogs")).rpartition("/")
    suite = ET.parse(xml).getroot()
    suite = suite if suite.tag == "testsuite" else suite.find("testsuite")
    failed = suite is not None and (int(suite.get("failures", 0)) + int(suite.get("errors", 0))) > 0
    secs = float(suite.get("time", 0) if suite is not None else 0)
    log = xml.with_name("test.log")
    # Every test.log starts with Bazel's pager line; the test's output follows.
    lines = log.read_text(errors="replace").splitlines() if log.exists() else []
    tail = [l for l in lines if not l.startswith("exec ${PAGER")][-15:]
    rows.append((f"//{pkg}:{name}", failed, secs, tail))

bad = [r for r in rows if r[1]]
if not rows:
    print(f"# No test results for {service}\n\nBazel wrote nothing under `{root}`: the build stopped before the tests ran.")
    sys.exit(0)
print(f"# {'❌' if bad else '✅'} {service}: {len(rows) - len(bad)} of {len(rows)} test targets passed\n")
print("| | Target | Time |\n|---|---|---:|")
for target, failed, secs, _ in rows:
    print(f"| {'❌' if failed else '✅'} | `{target}` | {secs:.1f} s |")
for target, failed, _, tail in rows:
    print(f"\n## {'❌' if failed else '✅'} `{target}`\n\n```\n" + "\n".join(tail) + "\n```")
