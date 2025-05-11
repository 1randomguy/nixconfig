#!/usr/bin/env just --justfile

update-os:
  nix flake update && sudo nixos-rebuild switch --flake . && git commit -am "update"

