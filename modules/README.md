# Modules

## モジュールの読み込まれ方

ディレクトリモジュールでは、OS に応じて以下のファイルが自動的に import されます：

| ファイル | 条件 |
|---------|------|
| `default.nix` | 常に import |
| `linux.nix` | Linux の場合のみ import |
| `darwin.nix` | macOS の場合のみ import |
