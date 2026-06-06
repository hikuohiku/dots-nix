---
name: dots-nix-verify
description: Use for dots-nix module changes, Nix flake validation, nix-darwin or NixOS build checks, and the local verify/commit/push workflow in this repository.
---

# dots-nix Verify

Use this skill when changing this repository's shared Nix modules, machine flakes, or app enablement. Prefer verifying local module changes with `--override-input my .` instead of temporarily editing a machine `flake.nix`.

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
4. For targeted checks, run `nix eval` against the option or value affected by the change.
5. For broader checks, run the platform build command with `--no-out-link`.
6. If validation fails, stop before committing and report the failure with the relevant command output.

Examples:

```bash
nix eval ./machines/hikuo-macbook#darwinConfigurations.hikuo-macbook.config.<option> --override-input my .
darwin-rebuild build --no-out-link --flake ./machines/hikuo-macbook --override-input my .

nix eval ./machines/hikuo-desktop#nixosConfigurations.hikuo-desktop.config.<option> --override-input my .
nixos-rebuild build --no-out-link --flake ./machines/hikuo-desktop --override-input my .
```

Do not edit `machines/<machine>/flake.nix` only to point `my` at the local checkout. Do not update or restore a machine `flake.lock` only for local validation.

## Commit And Push

When the user asks to commit, or the repository workflow implies committing after the change:

1. Stage only the files that belong to the current change.
2. Keep shared module changes separate from machine-specific lock updates when possible.
3. Commit shared dots-nix changes first and push `main`.
4. If a machine flake should consume the pushed shared module, run `nix flake update my --flake ./machines/<machine>`, commit the machine `flake.lock` and any machine-specific changes, then push again.

Never revert unrelated user changes. If temporary intent-to-add entries were used for validation and are not part of the final change, remove only those entries from the index before committing.
