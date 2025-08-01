#!/usr/bin/env just --justfile
rebuild := "sudo nixos-rebuild switch --flake ." 
#if shell('uname -a | grep NixOS') != "" {
#  "sudo nixos-rebuild switch --flake ."
#} else { 
#  "home-manager switch --flake ."
#}

rebuild:
  sudo nixos-rebuild switch --flake .

rebuild-hm:
  home-manager switch --flake .

update:
  git pull
  {{rebuild}}

upgrade:
  git pull
  nix flake update
  {{rebuild}}
  git add flake.lock
  git commit -m "upgrade"

upgrade-nixvim:
  git pull
  nix flake update nixvim
  {{rebuild}}
  git add flake.lock
  git commit -m "upgrade nixvim"

