let
  usopp_server  = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBJavj6UCLWWqDZkG5monO+7WAdn/jFvUqblN9SzURip root@usopp";
  usopp_bene_user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPq1IM31Z2YBs2XLPDwiNdmedBtMTBB+t7/yqwySCryU usopp_for_agenix";
  desktop_bene_user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII32Ud21QSaA2cUChs6LvIP+oE3ZA3h+hKiteOZ6VZXE agenix_bene_desktop";
  all = [ usopp_server usopp_bene_user desktop_bene_user ];
in
{
  "porkbun.age".publicKeys = all;
  "restic.age".publicKeys = all;
  "authelia_jwt_secret.age".publicKeys = all;
  "authelia_storage_encryption.age".publicKeys = all;
  "authelia_session_secret.age".publicKeys = all;
  "authelia_jwks.age".publicKeys = all;
  "authelia_hmac_secret.age".publicKeys = all;
  "ddclient_config.age".publicKeys = all;
}
