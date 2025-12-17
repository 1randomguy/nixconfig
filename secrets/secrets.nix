let
  usopp_server  = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBJavj6UCLWWqDZkG5monO+7WAdn/jFvUqblN9SzURip root@usopp";
  usopp_bene_user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPq1IM31Z2YBs2XLPDwiNdmedBtMTBB+t7/yqwySCryU usopp_for_agenix";
  desktop_bene_user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII32Ud21QSaA2cUChs6LvIP+oE3ZA3h+hKiteOZ6VZXE agenix_bene_desktop";
  sanji_bene_user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPCbATrAxuPLKk5UdhY5Jq9ONL+LQptpYgkisltGhu6R bene@sanji";
  worklaptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOnZllVInrxAQ6jQUQmdlNAhXwqp5ZbSfRfFnZYdphVn root@worklaptop";
  worklaptop_bene_user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOdx+/OhkagwQBQD+xYKWUejYggogSl0j5LTe3QBZst/ bene@worklaptop";
  private = [ usopp_server usopp_bene_user desktop_bene_user sanji_bene_user ];
  worklaptop_both = [ worklaptop worklaptop_bene_user ];
in
{
  "porkbun.age".publicKeys = private;
  "restic.age".publicKeys = private;
  "authelia_jwt_secret.age".publicKeys = private;
  "authelia_storage_encryption.age".publicKeys = private;
  "authelia_session_secret.age".publicKeys = private;
  "authelia_jwks.age".publicKeys = private;
  "authelia_hmac_secret.age".publicKeys = private;
  "ddclient_config.age".publicKeys = private;
  "backblazeb2.age".publicKeys = private;
  "auto_stacker_env.age".publicKeys = private;
  "nextcloud_admin_password.age".publicKeys = private;
  "nextcloud_secrets.age".publicKeys = private;

  "wireguard_work.age".publicKeys = worklaptop_both;
}
