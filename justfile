#!/usr/bin/env just --justfile
rebuild := if shell('uname -a | grep NixOS') != "" {
  "sudo nixos-rebuild switch --flake ."
} else { 
  "home-manager switch --flake ."
}

update:
  nix flake update
  {{rebuild}}
  git add flake.lock
  git commit -m "update"

update-nvim:
  nix flake update nixvim
  {{rebuild}}
  git add flake.lock
  git commit -m "update nixvim"

