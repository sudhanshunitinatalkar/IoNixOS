{
    flake.nixosModules.networking = { config, lib, pkgs, ... }:

    {
    environment.systemPackages = [ pkgs.iw pkgs.networkmanager ];

    networking = {
        networkmanager.enable = true;
        hostName = "ionix";
        networkmanager.wifi.powersave = false;    
        firewall.enable = false;
        # firewall.allowedTCPPorts = [ ];
        # firewall.allowedUDPPorts = [ ];
        
        networkmanager = {    
        ensureProfiles.environmentFiles = [ "/etc/wifi.env" ];
        ensureProfiles.profiles = {
            "datalogger" = {
            connection = {
                id = "ionix";
                type = "wifi";
                interface-name = "uap0";
                autoconnect = true;
                "autoconnect-priority" = -100; # Low priority
            };
            wifi = {
                mode = "ap";
                ssid = "$DEVICE_SSID";
                band = "bg"; 
            };
            wifi-security = {
                key-mgmt = "wpa-psk";
                psk = "ionix";
            };
            ipv4 = {
                method = "shared";
                address = "192.168.57.7/24";
            };
            ipv6 = { method = "ignore"; };
            };
        };
        };
    };

    systemd.services.generate-wifi-env = {
        description = "Generate unique SSID based on CPU ID";
        before = [ "NetworkManager.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig.Type = "oneshot";
        script = ''
        if [ ! -f /etc/wifi.env ]; then
            CPUID=$(${pkgs.coreutils}/bin/tr -d '\0' < /proc/device-tree/serial-number | ${pkgs.coreutils}/bin/tail -c 9)
            echo "DEVICE_SSID=''${CPUID}_577" > /etc/wifi.env
        fi
        '';
    };

    systemd.services.uap0 = {
        description = "Create uap0 virtual AP interface";
        requires = [ "sys-subsystem-net-devices-wlan0.device" ];
        after = [ "sys-subsystem-net-devices-wlan0.device" ];
        before = [ "NetworkManager.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStop = "${pkgs.iw}/bin/iw dev uap0 del";
        };
        script = ''
        if ${pkgs.iproute2}/bin/ip link show uap0 > /dev/null 2>&1; then
            exit 0
        fi
        # Dynamic MAC generation
        perm_mac=$(${pkgs.coreutils}/bin/cat /sys/class/net/wlan0/address)
        ua_mac=$(echo "$perm_mac" | ${pkgs.gawk}/bin/awk -F: '{printf("%02x:%s:%s:%s:%s:%s", strtonum("0x"$1) + 2, $2, $3, $4, $5, $6)}')
        ${pkgs.iw}/bin/iw dev wlan0 interface add uap0 type __ap addr "$ua_mac"
        '';
    };

    systemd.timers."uap0watchdog" = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = "2m";
        Unit = "uap0watchdog.service";
        };
    };

    systemd.services."uap0watchdog" = {
        description = "Restarts uap0 if it disappears";
        serviceConfig.Type = "oneshot";
        script = ''
        if ! ${pkgs.iproute2}/bin/ip link show uap0 > /dev/null 2>&1; then
            systemctl restart uap0.service
            ${pkgs.networkmanager}/bin/nmcli connection reload
            ${pkgs.networkmanager}/bin/nmcli connection up datalogger || true
        fi
        '';
    };
  };
}