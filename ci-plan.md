# CI/CDフロー設計

## 目的
- 設定ファイルの品質保証
- システム構成の整合性確認
- 自動化されたテストと検証

## CIパイプライン構成

### 1. 基本チェック
- **静的解析**
  - Nixの構文チェック
  - treefmtによるコードフォーマットチェック
  - 未使用の依存関係の検出

### 2. ビルドテスト
- **NixOS設定**
  - システム設定のビルドテスト
  - モジュールの依存関係チェック

- **Home Manager設定**
  - ユーザー環境設定のビルドテスト
  - パッケージのインストールテスト

### 3. セキュリティチェック
- **依存関係スキャン**
  - 既知の脆弱性チェック
  - 古いバージョンの検出

### 4. 自動更新
- **Dependabot**による依存関係の自動更新PR作成
  - nixpkgsの更新
  - その他の外部依存の更新

## ワークフロートリガー

1. プッシュ時
   - mainブランチへのプッシュ
   - プルリクエスト作成時

2. 定期実行
   - 依存関係の更新チェック（週1回）
   - セキュリティスキャン（日1回）

## 推奨GitHub Actions設定

```yaml
name: NixOS Configuration CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '0 0 * * 0'  # 週1回実行（日曜日の0時）

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Nix
        uses: cachix/install-nix-action@v25

      - name: Setup Cachix
        uses: cachix/cachix-action@v14
        with:
          name: ${{ secrets.CACHIX_NAME }}
          authToken: ${{ secrets.CACHIX_AUTH_TOKEN }}

      - name: Check Nix formatting
        run: nix fmt check

      - name: Run treefmt
        run: nix run .#formatter

      - name: Flake check
        run: nix flake check

  build:
    needs: check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Nix
        uses: cachix/install-nix-action@v25

      - name: Build NixOS configuration
        run: nix build .#nixosConfigurations.desktop.config.system.build.toplevel

      - name: Build Home Manager configuration
        run: nix build .#homeConfigurations.hikuo.activationPackage

  security:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run security scan
        uses: renovatebot/renovate@v37
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
```

## 期待される効果

1. **品質向上**
   - コードの一貫性維持
   - 早期のエラー検出
   - セキュリティリスクの軽減

2. **効率化**
   - 手動チェックの削減
   - 自動化された依存関係管理
   - ビルド問題の早期発見

3. **安定性向上**
   - システム構成の検証
   - 互換性の確保
   - リグレッションの防止

## 次のステップ

1. GitHub Actionsの設定ファイル実装
2. Cachixの設定
3. セキュリティスキャンの詳細設定
4. 通知設定の調整