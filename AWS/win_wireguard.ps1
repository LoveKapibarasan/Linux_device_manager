New-Item -ItemType Directory -Path "C:\wg" -Force
New-Item -ItemType File -Path "C:\wg\client.conf" -Force
notepad "C:\wg\client.conf"

# It need to be admin to open ui