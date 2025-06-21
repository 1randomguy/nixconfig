let
  usopp_server  = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBJavj6UCLWWqDZkG5monO+7WAdn/jFvUqblN9SzURip root@usopp";
in
{
  "porkbun.age".publicKeys = [ usopp_server ];
}
