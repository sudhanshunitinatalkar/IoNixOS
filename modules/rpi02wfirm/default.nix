{
  flake.nixosModules.rpi02wfirm = { pkgs, lib, ... }: {
    # 1. Device Tree & Overlays (Hardware Definitions)
    hardware = {
      enableRedistributableFirmware = lib.mkForce true;
      deviceTree = {
        enable = true;
        filter = "*rpi-zero-2-w.dtb";
        overlays = [
          # ssd1306 0.96 spi oled 128x64 Overlay
          {
            name = "ssd1306-overlay";
            dtsText = ''
              /dts-v1/;
              /plugin/;
              / {
                  compatible = "brcm,bcm2837";

                  /* A. Configure GPIOs 24 (Reset) and 25 (DC) as outputs */
                  fragment@0 {
                      target = <&gpio>;
                      __overlay__ {
                          oled_pins: oled_pins {
                              brcm,pins = <24 25>;
                              brcm,function = <1>; /* 1 = Output */
                              brcm,pull = <0>;     /* 0 = No Pull */
                          };
                      };
                  };

                  /* B. Attach the SSD1306 to SPI0 */
                  fragment@1 {
                      target = <&spi0>;
                      __overlay__ {
                          status = "okay";
                          #address-cells = <1>;
                          #size-cells = <0>;

                          /* Disable user-space SPIDEV so the kernel driver can bind */
                          spidev@0 { status = "disabled"; };
          
                          oled: oled@0 {
                              compatible = "solomon,ssd1306";
                              reg = <0>; /* Chip Select 0 (CE0) */
                              pinctrl-names = "default";
                              pinctrl-0 = <&oled_pins>;
                              
                              /* SPI Clock Frequency */
                              spi-max-frequency = <10000000>; /* 10 MHz */
                              
                              /* Data/Command and Reset GPIO Bindings */
                              dc-gpios = <&gpio 25 0>;    /* 0 = Active High */
                              reset-gpios = <&gpio 24 1>; /* 1 = Active Low (Standard for Reset) */
                              
                              /* Screen Geometry */
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

    # 2. Kernel Parameters (TTY / Framebuffer Configuration)
    # The Pi's built-in HDMI is normally /dev/fb0. The OLED will likely spawn as /dev/fb1.
    boot.kernelParams = [
      "fbcon=map:1"        # Map the primary console to /dev/fb1
      "fbcon=font:VGA8x8"  # Use a tiny 8x8 font so you can actually read text (16 cols x 8 rows)
    ];

    # 3. Kernel Modules to Load
    boot.kernelModules = [ "spi-bcm2835" "ssd130x-spi" ];

    # 4. BUILD-TIME CONFIG.TXT GENERATION
    sdImage.populateFirmwareCommands = ''
      (
        echo "dtparam=spi=on"
        echo "dtparam=watchdog=on"
      ) >> firmware/config.txt
    '';
  };
}