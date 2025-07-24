# 🔐 LUKS Encryption + Cracking Lab (Linux)

This is a fully CLI-based lab to:

- Encrypt a USB flash drive with LUKS using a weak password
- Extract the LUKS header
- Generate a hash using `luks2john`
- Crack the password using `John the Ripper` + `rockyou.txt`

---

## ⚠️ DISCLAIMER

> This project is for **educational and ethical hacking purposes** only. Never use it on unauthorized devices.

---

## 🧰 Requirements

Install required tools:

```bash
sudo dnf install cryptsetup john util-linux coreutils -y
sudo dnf install wordlists
sudo gunzip /usr/share/wordlists/rockyou.txt.gz
