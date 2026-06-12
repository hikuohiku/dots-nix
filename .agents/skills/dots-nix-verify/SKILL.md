---
name: dots-nix-verify
description: Use for dots-nix module changes, Nix flake validation, nix-darwin or NixOS build checks, and the local verify/commit/push workflow in this repository.
---

# dots-nix Verify

Use this skill when changing this repository's shared Nix modules, machine flakes, or app enablement. Follow the same flow as `.claude/commands/nix-module-ci.md`: validate the local checkout with `--override-input my .`, apply the change locally with `switch` after a successful build, then gate commit/push on the user's runtime confirmation.

## Select Target

- Default to `hikuo-macbook` when the user does not specify a machine.
- Use `hikuo-macbook` for darwin or macOS changes.
- Use `hikuo-desktop` for NixOS, Linux, desktop, systemd, or NixOS-only changes.
- If both platforms are affected, verify both.

Machine paths:

- macOS: `./machines/hikuo-macbook`
- NixOS: `./machines/hikuo-desktop`

Configuration outputs:

- macOS: `darwinConfigurations.hikuo-macbook`
- NixOS: `nixosConfigurations.hikuo-desktop`

## Local Validation

1. Run `git status --short` before staging or editing.
2. If a new file must be visible to Nix flakes during validation, prefer `git add -N <path>` so the path is tracked intent-only. Use normal `git add` only when preparing the final commit.
3. Use `--override-input my .` so the machine flake evaluates the current local repository.
4. For targeted checks, run `nix eval` against the option or value affected by the change when there is a useful narrow value to inspect.
5. Run the platform build command for each affected target:
   - macOS: `darwin-rebuild build --flake ./machines/hikuo-macbook --override-input my .`
   - NixOS: `nix build ./machines/hikuo-desktop#nixosConfigurations.hikuo-desktop.config.system.build.toplevel --override-input my . --no-link --print-out-paths`
6. Do not use `nixos-rebuild build` for NixOS CI in this repository. The installed ng `nixos-rebuild` does not support the expected `--no-out-link` flow; use `nix build` as above.
7. Do not edit `machines/<machine>/flake.nix` only to point `my` at the local checkout.
8. Do not update or restore a machine `flake.lock` only for local validation.
9. If validation fails, stop before applying, committing, or pushing. Report the failing command and relevant output.

## Apply And Push Gate

Build success only proves evaluation/build correctness. After the build succeeds, apply the local checkout to the affected machine before commit/push.

Both machines have rebuild commands configured for passwordless sudo:

- NixOS: `machines/hikuo-desktop/modules/claude-rebuild.nix`
- macOS: `machines/hikuo-macbook/modules/claude-rebuild.nix`

Run the matching switch command automatically after a successful build:

```bash
sudo nixos-rebuild switch --flake ./machines/hikuo-desktop --override-input my .
sudo darwin-rebuild switch --flake ./machines/hikuo-macbook --override-input my .
```

For Codex, these switch commands must be run with escalated sandbox permissions because activation writes outside the workspace (`/nix/var`, `/boot`, systemd, launchd, `/etc`, and related system locations).

If activation fails, stop and do not commit or push.

If activation succeeds, ask the user for the runtime confirmation result before pushing:

- Runtime check OK: proceed to commit/push when requested or when the workflow implies it.
- Cannot check / not needed: proceed to commit/push when requested or when the workflow implies it.
- Do not push yet: stop before commit/push.

Examples:

```bash
nix eval ./machines/hikuo-macbook#darwinConfigurations.hikuo-macbook.config.<option> --override-input my .
darwin-rebuild build --flake ./machines/hikuo-macbook --override-input my .
sudo darwin-rebuild switch --flake ./machines/hikuo-macbook --override-input my .

nix eval ./machines/hikuo-desktop#nixosConfigurations.hikuo-desktop.config.<option> --override-input my .
nix build ./machines/hikuo-desktop#nixosConfigurations.hikuo-desktop.config.system.build.toplevel --override-input my . --no-link --print-out-paths
sudo nixos-rebuild switch --flake ./machines/hikuo-desktop --override-input my .
```

## Commit And Push

When the user asks to commit, or the repository workflow implies committing after the change:

1. Stage only the files that belong to the current change.
2. Keep shared module changes separate from machine-specific lock updates when possible.
3. Commit shared dots-nix changes first and push `main`.
4. If a machine flake should consume the pushed shared module, run `nix flake update my --flake ./machines/<machine>`, commit the machine `flake.lock` and any machine-specific changes, then push again.

Never revert unrelated user changes. If temporary intent-to-add entries were used for validation and are not part of the final change, remove only those entries from the index before committing.
