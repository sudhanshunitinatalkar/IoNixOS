# IoNixOS/modules/openocd/default.nix
{
    flake.nixosModules.openocd = { pkgs, ... }: {
    # Open the standard OpenOCD ports for remote access
    networking.firewall.allowedTCPPorts = [ 3333 4444 6666 ];

    systemd.services.openocd-bridge = {
        description = "Wireless OpenOCD Bridge Server";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        
        serviceConfig = {
        # Use noinit to stay in the configuration stage.
        # This allows the laptop to push the target-specific .cfg later.
        ExecStart = ''
            ${pkgs.openocd}/bin/openocd \
            -c "bindto 0.0.0.0" \
            -c "adapter driver linuxgpiod" \
            -c "adapter gpio swdio 19" \
            -c "adapter gpio swclk 26" \
            -c "transport select swd" \
            -c "noinit"
        '';
        Restart = "always";
        User = "root"; # Required for bcm2835gpio memory mapping
        };
    };
    };
}