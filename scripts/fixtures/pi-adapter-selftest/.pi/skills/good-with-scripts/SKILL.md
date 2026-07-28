---
name: fixture-good-scripts-check
description: Fixture skill with a real same-directory scripts/ resource and a repo-root scripts/ mention in prose, used only to regression-test validate-pi-adapter.sh's scripts/ path handling (both the positive same-directory case and the repo-root whitelist).
---

# fixture-good-scripts-check

Run `scripts/real.sh` for setup.

See also `scripts/sync-adapters.sh` at the repo root for how this project's sync pipeline works — this is a prose mention of a repo-level script, not a same-directory resource, and must not be flagged as a broken reference.
