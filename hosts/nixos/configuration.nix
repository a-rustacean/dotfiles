{
  pkgs,
  user,
  hostname,
  inputs,
  system,
  ...
}:
{
  system.stateVersion = "26.05";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.zfs.forceImportRoot = false;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  networking.hostName = hostname;
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      80
      443
      8080
      8000
    ];
  };

  time.timeZone = "Asia/Kolkata";

  services.displayManager.ly.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = [ ];
    shell = pkgs.zsh;
    initialPassword = user; # username is the default password
  };

  programs.zsh.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = inputs.hyprland.packages.${system}.hyprland;
    portalPackage = inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland;
  };

  environment.sessionVariables = {
    LIBGL_ALWAYS_SOFTWARE = "1";
  };

  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];
}
