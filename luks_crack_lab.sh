#!/bin/bash

set -e

# AUTO-DETECT USB DEVICE
DEVICE=$(lsblk -o NAME,SIZE,MODEL | grep -i "usb" | awk '{print "/dev/" $1}' | head -n1)

if [ -z "$DEVICE" ]; then
  echo "[!] No USB device found. Insert your flash drive and try again."
  exit 1
fi

MAPPER_NAME="cracktest"
MOUNT_POINT="/mnt/usb"
HEADER_OUT="luks-header.img"
HASH_OUT="luks.hash"
WORDLIST="/usr/share/wordlists/rockyou.txt"

echo "[*] WARNING: This will ERASE ALL DATA on $DEVICE!"
read -p "Type YES to continue: " confirm
[ "$confirm" != "YES" ] && exit 1

echo "[*] Wiping old filesystem..."
sudo wipefs -a "$DEVICE"
sudo dd if=/dev/zero of="$DEVICE" bs=1M count=100 status=progress

echo "[*] Encrypting $DEVICE with weak password 'password123'..."
echo -n "password123" | sudo cryptsetup luksFormat "$DEVICE" -

echo "[*] Opening encrypted volume..."
echo -n "password123" | sudo cryptsetup luksOpen "$DEVICE" "$MAPPER_NAME" -

echo "[*] Formatting as ext4..."
sudo mkfs.ext4 /dev/mapper/"$MAPPER_NAME"

echo "[*] Mounting volume..."
sudo mkdir -p "$MOUNT_POINT"
sudo mount /dev/mapper/"$MAPPER_NAME" "$MOUNT_POINT"

echo "[*] Writing test file..."
echo "Top secret test file" | sudo tee "$MOUNT_POINT/test.txt" > /dev/null

echo "[*] Unmounting and closing..."
sudo umount "$MOUNT_POINT"
sudo cryptsetup luksClose "$MAPPER_NAME"

echo "[*] Extracting LUKS header..."
sudo dd if="$DEVICE" of="$HEADER_OUT" bs=512 count=2048 status=progress

echo "[*] Generating hash with luks2john..."
luks2john "$HEADER_OUT" > "$HASH_OUT"

echo "[*] Cracking LUKS password using John..."
if [ ! -f "$WORDLIST" ]; then
  echo "[-] Wordlist not found. Installing..."
  sudo dnf install wordlists -y
  sudo gunzip /usr/share/wordlists/rockyou.txt.gz
fi

john --wordlist="$WORDLIST" "$HASH_OUT"
