{
  flake.nixosModules.rpi02wfirm = { pkgs, lib, ... }: {
    hardware = {
      enableRedistributableFirmware = lib.mkForce true;
      deviceTree = {
        enable = true;
        filter = "*rpi-zero-2-w.dtb";
        overlays = [
          {
            name = "ssd1306-overlay";
            dtsText = ''
              /dts-v1/;
              /plugin/;
              / {
                  compatible = "brcm,bcm2837";
                  fragment@0 {
                      target = <&gpio>;
                      __overlay__ {
                          oled_pins: oled_pins {
                              brcm,pins = <24 25>;
                              brcm,function = <1>; 
                              brcm,pull = <0>;
                          };
                      };
                  };

                  fragment@1 {
                      target = <&spi0>;
                      __overlay__ {
                          status = "okay";
                          #address-cells = <1>;
                          #size-cells = <0>;
                          spidev@0 { status = "disabled"; };
          
                          oled: oled@0 {
                              compatible = "solomon,ssd1306";
                              reg = <0>; 
                              pinctrl-names = "default";
                              pinctrl-0 = <&oled_pins>;
                              spi-max-frequency = <10000000>;
                              dc-gpios = <&gpio 25 0>;    
                              reset-gpios = <&gpio 24 1>; 
                              solomon,width = <128>;
                              solomon,height = <64>;
                              solomon,page-offset = <0>;
                              solomon,com-invdir;
                          };
                      };
                  };
              };
            '';
          }
        ];
      };
    };

    # Load these in the initial RAM disk so the screen exists for earlySetup
    boot.initrd.kernelModules = [ "spi-bcm2835" "ssd130x-spi" ];
    
    # Keep your existing line as well
    boot.kernelModules = [ "spi-bcm2835" "ssd130x-spi" ];
    
    # Block the staging driver that was causing the 'quality unknown' warning
    boot.blacklistedKernelModules = [ "fb_ssd1306" "fbtft" ];

    sdImage.populateFirmwareCommands = ''
      (
        echo "dtparam=spi=on"
        echo "dtparam=watchdog=on"
      ) >> firmware/config.txt
    '';
  };
}