#!/usr/bin/env just --justfile
rebuild := "sudo nixos-rebuild switch --flake ." 
#if shell('uname -a | grep NixOS') != "" {
#  "sudo nixos-rebuild switch --flake ."
#} else { 
#  "home-manager switch --flake ."
#}

rebuild:
  sudo nixos-rebuild switch --flake .
  # The hyphen tells `just` to ignore errors if this fails
  -systemctl --user try-restart elephant.service

usopp:
  nixos-rebuild switch --flake .#usopp --sudo --target-host bene@192.168.178.57
