{
  flake.nixosModules.configuration = { inputs, pkgs, ... }:
  {

    nix.settings = 
    {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "sudha" ];
    };
    system.stateVersion = "25.11";
    nixpkgs.config.allowUnfree = true;

    boot =
    {
      kernelPackages = pkgs.linuxPackages_rpi02w;
      loader.grub.enable = false;
    };

    hardware.bluetooth.enable = true;

    networking =
    {
      hostName = "ionix";
      networkmanager.enable = true;
      firewall.enable = false;
      # firewall.allowedTCPPorts = [ ];
      # firewall.allowedUDPPorts = [ ];
    };

    users.groups.gpio = {};
      
    users.users.root = 
    {
      initialPassword = "ionix";
    };

    users.users.ionix = 
    {
      initialPassword = "ionix";
      isNormalUser = true;
      extraGroups = [ "wheel" "i2c" "networkmanager" "dialout" "gpio" ];
    };

    time = 
    {
      timeZone = "Asia/Kolkata";
      hardwareClockInLocalTime = true;
    };
    
    services =
    {
      openssh.enable = true;
    };

    environment.systemPackages = with pkgs;
    [
      tree
      util-linux
      vim
      wget
      curl
      git
      gptfdisk
      htop
      networkmanager
      fastfetch
      neofetch
      minicom
      ppp
      openocd
    ];

    i18n.defaultLocale = "en_US.UTF-8";
    console =
    {
      font = "Lat2-Terminus16";
      keyMap = "us";
    };   

  };
}
