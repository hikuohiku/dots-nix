# neovim/vscode: Migrated to modules-2/neovim/ and modules-2/vscode/
{ mylib, ... }:
{
  imports = mylib.listPlatformModules ./.;
}
