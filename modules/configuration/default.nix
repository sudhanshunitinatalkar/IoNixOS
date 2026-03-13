{
  flake.nixosModules.configuration = { inputs, pkgs, lib, ... }:
  {

    nix.settings = 
    {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "ionix" ];
      
    };
    system.stateVersion = "25.11";

    nixpkgs.config.allowUnfree = true;
    nixpkgs.overlays = [
      (final: prev: {
        makeModulesClosure = x: prev.makeModulesClosure (x // { allowMissing = true; });
      })
    ];

   boot = {
      kernelPackages = pkgs.linuxPackages_rpi02w;
      loader.grub.enable = false;
      supportedFilesystems = lib.mkForce [ "vfat" "ext4" ];
      loader.generic-extlinux-compatible.enable = true;
      
      # Completely silence the initramfs boot stage
      initrd.verbose = false;
      
      kernelParams = [
        "fbcon=map:2"                   # KEEP WHICHEVER NUMBER WORKED!
        "quiet"                         # Suppress kernel logs
        "loglevel=0"                    # Suppress all but emergency panics
        "systemd.show_status=false"     # Stop systemd's [ OK ] messages
        "rd.systemd.show_status=false"  # Stop systemd messages in initrd
        "rd.udev.log_level=0"           # Silence device manager logs
      ];
      
      consoleLogLevel = 0; 
    };

    hardware.bluetooth.enable = true;

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
      udev.extraRules = ''
        SUBSYSTEM=="gpio", GROUP="gpio", MODE="0660"
        SUBSYSTEM=="gpiodev", GROUP="gpio", MODE="0660"
        KERNEL=="gpiochip*", GROUP="gpio", MODE="0660"
        '';
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
    console = {
      font = "${./tom-thumb.psf}"; 
      keyMap = "us";
    };  

  };
}
