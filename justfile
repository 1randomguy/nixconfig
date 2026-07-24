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
  -systemctl --user restart vicinae.service

chopper:
  nixos-rebuild switch --flake .#chopper --target-host bene@chopper.fritz.box --use-remote-sudo

usopp:
  nixos-rebuild switch --flake .#usopp --sudo --target-host bene@192.168.178.57
