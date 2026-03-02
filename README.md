# IoNixOS

# protos_stfs
# iot

nixos-rebuild switch --flake .#protos --target-host datalogger@192.168.57.7 --sudo --ask-sudo-password


grep . /proc/device-tree/soc/i2c@*/status

lsmod | grep i2c

ls -l /dev/i2c*

tr -d '\0' < /proc/device-tree/soc/i2c@7e804000/status

      
# Example flashing command (replace /dev/sdX with your actual SD card)
sudo dd if=result/sd-image/nixos-sd-image-*.img of=/dev/sda bs=4M status=progress conv=fsyn

cachix watch-exec protosstfs -- nix build .#nixosConfigurations.protos.config.system.build.toplevel

sudo nixos-rebuild switch --flake "git+https://b28f8ce79c48b7bd4433a75d70b0d87f3814c9f4@git.eltros.in/sudhanshu/datalogger_protos.git#protos"





export CACHIX_ACTIVATE_TOKEN=eyJhbGciOiJIUzI1NiJ9.eyJqdGkiOiI3Y2QzZTkzMS0zNTBmLTQyOGMtOTY0NC1kOTQ2N2Q4YzRiOTAiLCJzY29wZXMiOiJhY3RpdmF0ZSJ9.LAuFUxdpxl7kMOCNgvyw6V0PxqNHXnrDRIhVn6GZ7cM

nix build .#deploy

cachix push protosstfs result

cachix deploy activate result






#!/usr/bin/env bash
set -e

echo "🔨 Building System (Laptop Side)..."
# 1. Build the system locally
nix build .#nixosConfigurations.protos.config.system.build.toplevel --system aarch64-linux

echo "☁️ Uploading to Cache..."
# 2. Upload binaries to Cachix
cachix push protosstfs result

echo "📝 Updating Pointer..."
# 3. Write the new hash to the text file
readlink -f result > current_system_hash.txt

# 4. Publish the new pointer
git add current_system_hash.txt
git commit -m "Deploy: Update fleet to $(cat current_system_hash.txt)"
git push origin main

echo "✅ Update Published! Devices will pull it within 1 minute."


nix build .#nixosConfigurations.ionix.config.system.build.sdImage
