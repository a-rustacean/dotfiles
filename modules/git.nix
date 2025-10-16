{ config }:
{
  enable = true;
  userName = "Dilshad";
  userEmail = "a-rustacean@outlook.com";
  lfs = {
    enable = true;
    skipSmudge = true;
  };
  signing = {
    signByDefault = true;
    key = "95BBBA7922AE1CEC";
    signer = "${config.programs.gpg.package}/bin/gpg2";
  };
  extraConfig = {
    init.defaultBranch = "main";
  };
}
