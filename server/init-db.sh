#!/usr/bin/env bash

source .env

cd ~/Linux_device_manager/server
cat > init-db.sql << EOF
CREATE DATABASE IF NOT EXISTS roundcube;
CREATE USER IF NOT EXISTS 'roundcube'@'%' IDENTIFIED BY '${ROUNDCUBE_DB_PASSWORD}';
GRANT ALL PRIVILEGES ON roundcube.* TO 'roundcube'@'%';

CREATE DATABASE IF NOT EXISTS wordpress;
CREATE USER IF NOT EXISTS 'wordpress'@'%' IDENTIFIED BY '${WORDPRESS_DB_PASSWORD}';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'%';

FLUSH PRIVILEGES;
EOF