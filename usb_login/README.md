# Secure USB-Based Login Authentication with PAM and GPG

This setup enables **cryptographic login authentication** using a **USB device** and a **GPG-encrypted token**. A user can only log in if:

- A specific USB device is connected
- The token on the USB can be successfully decrypted and verified

This can be integrated with **PAM (`pam_exec.so`)** to enforce USB presence as a login condition.

---

## 🔐 Concept

- A secret string (e.g., `"LOGIN_OK"`) is encrypted using **GPG**
- The encrypted file `auth_token.gpg` is stored on a USB device
- A **PAM script** decrypts this file during login and compares it to the expected value
- If valid → login is allowed; otherwise → denied

---

## 📂 Example Token File (`auth_token.gpg`)

The following creates a symmetric-encrypted file containing `"LOGIN_OK"`:

```bash
echo "LOGIN_OK" | gpg --symmetric --cipher-algo AES256 -o /media/usb/auth_token.gpg
```

> You will be prompted to enter a passphrase used to decrypt the file during login.

---

## 📜 Manual

### 1. 🔍 Identify USB Mount Path

Insert your USB device and find its mount point, e.g., `/media/usb`:

```bash
lsblk
```

Make sure your encrypted token is stored at:

```text
/media/usb/auth_token.gpg
```

---

### 2. 📜 Create PAM Authentication Script

Create a file at `/usr/local/sbin/usb_crypt_login.sh`:

```bash
#!/bin/bash

USB_MOUNT="/media/usb"
TOKEN_FILE="$USB_MOUNT/auth_token.gpg"
EXPECTED="LOGIN_OK"

# Check if the token file exists
if [ ! -f "$TOKEN_FILE" ]; then
  echo "Token file not found." >&2
  exit 1
fi

# Decrypt the token
DECRYPTED=$(gpg --quiet --batch --yes --passphrase "your-passphrase" --decrypt "$TOKEN_FILE" 2>/dev/null)

# Validate the result
if [ "$DECRYPTED" = "$EXPECTED" ]; then
  exit 0
else
  echo "Invalid or missing token." >&2
  exit 1
fi
```

> Replace `"your-passphrase"` with your actual decryption password or configure GPG to use a keyring or `gpg-agent`.

Make it executable:

```bash
sudo chmod +x /usr/local/sbin/usb_crypt_login.sh
```

---

### 3. 🔐 Configure PAM

Edit the relevant PAM configuration file.

For SSH:
```bash
sudo nano /etc/pam.d/sshd
```

For console login:
```bash
sudo nano /etc/pam.d/login
```

Add this line near the top of the file:

```pam
auth required pam_exec.so /usr/local/sbin/usb_crypt_login.sh
```

---

### 4. ✅ Test the System

1. Try logging in **with** the USB plugged in and `auth_token.gpg` present → Login should succeed
2. Try logging in **without** the USB or with a tampered token → Login should fail

---

## 🛡️ Security Notes

- Use **strong passphrases** when encrypting the token
- Protect the USB device from unauthorized access
- Consider using **public/private key encryption** (GPG asymmetric mode) instead of symmetric
- For enhanced security, use a **smartcard** or **hardware security key (e.g., YubiKey)** with GPG

---

## 📁 Sample Filesystem Structure on USB

```text
/media/usb/
├── auth_token.gpg
```

---

## 🔄 Cleanup or Reset

To regenerate the token:

```bash
echo "LOGIN_OK" | gpg --symmetric -o /media/usb/auth_token.gpg
```

To disable the login requirement:

- Remove or comment out the PAM line:
  ```pam
  # auth required pam_exec.so /usr/local/sbin/usb_crypt_login.sh
  ```

---

## 🧪 Troubleshooting

- Check PAM logs with:
  ```bash
  sudo journalctl -xe
  ```

- Test the script standalone:
  ```bash
  /usr/local/sbin/usb_crypt_login.sh && echo "OK" || echo "DENIED"
  ```

- Ensure GPG works in non-interactive mode; `gpg-agent` may be needed for password caching.

---
