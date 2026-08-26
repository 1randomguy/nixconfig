let
  desktop_bene_user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII32Ud21QSaA2cUChs6LvIP+oE3ZA3h+hKiteOZ6VZXE agenix_bene_desktop";
  sanji_bene_user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPCbATrAxuPLKk5UdhY5Jq9ONL+LQptpYgkisltGhu6R bene@sanji";
  sanji_system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKrCrb0IgesCvYGXNm0bYMvkYMyJRSNPq5aWgpYhTdPB root@sanji";
  chopper_bene_user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDs5g0mp6Uwglxzt6XctUCD7YbvC2Fx8wyewUKp3o5W0 bene@chopper";
  chopper_system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMcOyB/4MhZufiivqo8sL+w8CVPZFrMV6GnVd6wDFcD/ root@chopper";
  worklaptop_system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOnZllVInrxAQ6jQUQmdlNAhXwqp5ZbSfRfFnZYdphVn root@worklaptop";
  worklaptop_bene_user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOdx+/OhkagwQBQD+xYKWUejYggogSl0j5LTe3QBZst/ bene@worklaptop";
  all_users = [ chopper_bene_user desktop_bene_user sanji_bene_user worklaptop_bene_user ];
  chopper = all_users ++ [ chopper_system ];
  sanji = all_users ++ [ sanji_system ];
  worklaptop = all_users ++ [ worklaptop_system ];
in
{
  "porkbun.age".publicKeys = chopper;
  "restic.age".publicKeys = chopper;
  "authelia_jwt_secret.age".publicKeys = chopper;
  "authelia_storage_encryption.age".publicKeys = chopper;
  "authelia_session_secret.age".publicKeys = chopper;
  "authelia_jwks.age".publicKeys = chopper;
  "authelia_hmac_secret.age".publicKeys = chopper;
  "ddclient_config.age".publicKeys = chopper;
  "ddns-updater.age".publicKeys = chopper;
  "backblazeb2.age".publicKeys = chopper;
  "auto_stacker_env.age".publicKeys = chopper;
  "nextcloud_admin_password.age".publicKeys = chopper;
  "nextcloud_secrets.age".publicKeys = chopper;
  "ntfy_url.age".publicKeys = chopper;
  "crowdsec_token.age".publicKeys = chopper;
  "subwave-env.age".publicKeys = chopper;
  "smb_secrets.age".publicKeys = sanji;

  "wireguard_work.age".publicKeys = worklaptop;
}
