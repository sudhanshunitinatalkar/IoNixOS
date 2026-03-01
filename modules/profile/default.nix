{
  flake.nixosModules.plasma = { pkgs, inputs, ... }:

  {
    imports = [ inputs.home-manager.nixosModules.home-manager ];
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = { inherit inputs; };
      
      users.ionix = {
        home.stateVersion = "25.11";

        home.packages = with pkgs; [
          tree
          util-linux
          vim
          wget
          curl
          git
          gptfdisk
          htop
          fastfetch
          android-tools
          sops
          pciutils
          mosquitto
          python3
        ];   
      };
    };
  };
}