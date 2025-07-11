let
  usopp_server  = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBJavj6UCLWWqDZkG5monO+7WAdn/jFvUqblN9SzURip root@usopp";
  usopp_bene_user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPq1IM31Z2YBs2XLPDwiNdmedBtMTBB+t7/yqwySCryU usopp_for_agenix";
  desktop_bene_user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII32Ud21QSaA2cUChs6LvIP+oE3ZA3h+hKiteOZ6VZXE agenix_bene_desktop";
in
{
  "porkbun.age".publicKeys = [ usopp_server usopp_bene_user desktop_bene_user ];
  "restic.age".publicKeys = [ usopp_server usopp_bene_user desktop_bene_user ];
  "authelia_jwt_secret.age".publicKeys = [ usopp_server usopp_bene_user desktop_bene_user ];
  "authelia_storage_encryption.age".publicKeys = [ usopp_server usopp_bene_user desktop_bene_user ];
  "authelia_session_secret.age".publicKeys = [ usopp_server usopp_bene_user desktop_bene_user ];
  "ddclient_config.age".publicKeys = [ usopp_server usopp_bene_user desktop_bene_user ];
}
