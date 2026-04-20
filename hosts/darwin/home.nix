{
  pkgs,
  ...
}:
{
  imports = [ ../../modules/home.nix ];

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry_mac;
  };
}
