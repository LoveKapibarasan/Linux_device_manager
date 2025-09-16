#!/bin/bash

add_domain() {
    local TYPE="$1"
    local DOMAIN="$2"
    local DB="$3"

    if [ -z "$TYPE" ] || [ -z "$DOMAIN" ] || [ -z "$DB" ]; then
        echo "Usage: add_domain <type> <domain> <db_path>"
        return 1
    fi

    # もし別の type で存在していたら削除して入れ替え
    local EXISTS_OTHER
    EXISTS_OTHER=$(sqlite3 "$DB" "SELECT COUNT(*) FROM domainlist WHERE domain='$DOMAIN' AND type<>$TYPE;")
    if [ "$EXISTS_OTHER" -gt 0 ]; then
        echo "Conflict: domain=$DOMAIN exists with another type → replacing..."
        sqlite3 "$DB" "DELETE FROM domainlist WHERE domain='$DOMAIN';"
    fi

    # 同じ type で存在していたらスキップ
    local EXISTS
    EXISTS=$(sqlite3 "$DB" "SELECT COUNT(*) FROM domainlist WHERE domain='$DOMAIN' AND type=$TYPE;")
    if [ "$EXISTS" -gt 0 ]; then
        echo "Already exists: type=$TYPE, domain=$DOMAIN"
        return 0
    fi

    # 挿入
    sqlite3 "$DB" "INSERT INTO domainlist (type, domain) VALUES ($TYPE, '$DOMAIN');"

    if [ $? -eq 0 ]; then
        echo "Added: type=$TYPE, domain=$DOMAIN"
    else
        echo "Error inserting into DB"
        return 1
    fi
}


