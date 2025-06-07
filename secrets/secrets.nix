let
  usopp = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPF3Oh3EEpDAXmBfwCyaP1pjFJITr3GRxuIR0fEKAo9Z";
  users = [ usopp ];
  usopp_server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIELVAYUeJtD5T0oZtGlbIivwnRcLCnvSZ26u3JF2Agmp root@nixos";
in
{
  "porkbun.age".publicKeys = [ usopp usopp_server ];
}
