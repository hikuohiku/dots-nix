{ lib, pkgs }:
{
  name,
  binary,
  install,
}:
lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  if [ ! -x ${lib.escapeShellArg binary} ]; then
    verboseEcho ${lib.escapeShellArg "Installing ${name}"}
    run ${lib.getExe pkgs.bash} -o pipefail -c ${lib.escapeShellArg install}
    if [[ ! -v DRY_RUN && ! -x ${lib.escapeShellArg binary} ]]; then
      echo ${lib.escapeShellArg "${name} installer did not create ${binary}"} >&2
      exit 1
    fi
  fi
''
