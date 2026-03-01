{ inputs, config, ... }: 
{
  flake.nixosConfigurations."ionix" = inputs.nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    specialArgs = { inherit inputs; };
    modules =  
      (builtins.attrValues config.flake.nixosModules) ++ [
        { sdImage.compressImage = false; }
        "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    ]; 
  };
}