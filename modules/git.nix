{ config, ... }:
{
  programs.git = {
    enable = true;
    lfs = {
      enable = true;
      skipSmudge = true;
    };
    signing = {
      signByDefault = true;
      key = "95BBBA7922AE1CEC";
      signer = "${config.programs.gpg.package}/bin/gpg2";
    };
    settings = {
      user = {
        name = "Dilshad";
        email = "a-rustacean@outlook.com";
      };
      init.defaultBranch = "main";
    };
  };
}
