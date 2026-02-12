#!/usr/bin/env bash

if [ -f ../.env ]; then
  source ../.env
else
  echo "Error: .env file not found."
  exit 1
fi

cat > init.sql << EOF
DO \$$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = 'n8n') THEN
        CREATE USER n8n WITH PASSWORD '${N8N_DB_PASSWORD}';
    END IF;
END
\$$;
SELECT 'CREATE DATABASE n8n' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'n8n')\gexec
GRANT ALL PRIVILEGES ON DATABASE n8n TO n8n;

-- 2. Zulip用 (Collation設定が肝)
DO \$$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = 'zulip') THEN
        CREATE USER zulip WITH PASSWORD '${ZULIP_DB_PASSWORD}';
    END IF;
END
\$$;
ALTER USER zulip WITH SUPERUSER;
SELECT 'CREATE DATABASE zulip LC_COLLATE = ''C'' LC_CTYPE = ''C''' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'zulip')\gexec
GRANT ALL PRIVILEGES ON DATABASE zulip TO zulip;

DO \$$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = 'op') THEN
        CREATE USER op WITH PASSWORD '${OPENPROJECT_PASSWORD}';
    END IF;
END
\$$;
SELECT 'CREATE DATABASE op' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'op')\gexec
GRANT ALL PRIVILEGES ON DATABASE op TO op;

EOF
