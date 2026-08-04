# syntax=docker/dockerfile:1.7
FROM nixos/nix@sha256:29fc5fe207f159ceb0143c25c19c774062fee02ce5eda118f3067547b3054894 AS builder

WORKDIR /src
COPY . .

RUN activation_path="$(nix --extra-experimental-features "nix-command flakes" build --impure --override-input my path:/src ./machines/coder#homeConfigurations.coder.activationPackage --no-link --print-out-paths)" && printf '%s\n' "$activation_path" > /nix/coder-home-activation && cp -a /nix /export-nix

FROM codercom/enterprise-base@sha256:d8c9cbae2fb5b0546d7dbfffbfb39e4ab7e9921066648da22bf12f852f55b692

USER root
COPY --from=builder --chown=coder:coder /export-nix /nix
COPY machines/coder/activate-home.sh /usr/local/bin/coder-home-activate

RUN install -d -m 0755 /etc/nix && printf '%s\n' 'experimental-features = nix-command flakes' 'sandbox = false' 'build-users-group =' > /etc/nix/nix.conf && chmod 0755 /usr/local/bin/coder-home-activate

ENV NIX_REMOTE=local PATH=/home/coder/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

USER coder
