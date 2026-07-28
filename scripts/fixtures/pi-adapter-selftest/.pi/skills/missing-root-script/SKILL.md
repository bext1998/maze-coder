---
name: fixture-missing-root-script-check
description: Fixture skill that mentions a whitelisted repo-root script which does not exist in the fixture repo root's scripts/ directory, used only to regression-test validate-pi-adapter.sh's whitelist existence check (basename match alone must not pass).
---

# fixture-missing-root-script-check

See `scripts/validate-skillpack.sh` at the repo root — this name is on the validator's
repo-root script whitelist, but the fixture repo root deliberately does not contain it,
so the validator must report BAD_PATH instead of passing on basename alone.
