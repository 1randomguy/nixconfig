let
  desktop_bene_user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII32Ud21QSaA2cUChs6LvIP+oE3ZA3h+hKiteOZ6VZXE agenix_bene_desktop";
  sanji_bene_user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPCbATrAxuPLKk5UdhY5Jq9ONL+LQptpYgkisltGhu6R bene@sanji";
  chopper_server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMcOyB/4MhZufiivqo8sL+w8CVPZFrMV6GnVd6wDFcD/ root@chopper";
  chopper_bene_user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDs5g0mp6Uwglxzt6XctUCD7YbvC2Fx8wyewUKp3o5W0 bene@chopper";
  private = [ chopper_server chopper_bene_user desktop_bene_user sanji_bene_user ];
  worklaptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOnZllVInrxAQ6jQUQmdlNAhXwqp5ZbSfRfFnZYdphVn root@worklaptop";
  worklaptop_bene_user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOdx+/OhkagwQBQD+xYKWUejYggogSl0j5LTe3QBZst/ bene@worklaptop";
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
  "ddns-updater.age".publicKeys = private;
  "backblazeb2.age".publicKeys = private;
  "auto_stacker_env.age".publicKeys = private;
  "nextcloud_admin_password.age".publicKeys = private;
  "nextcloud_secrets.age".publicKeys = private;
  "ntfy_url.age".publicKeys = private;
  "crowdsec_token.age".publicKeys = private;

  "wireguard_work.age".publicKeys = worklaptop_both;
}
