# gravity db

* `/etc/pihole/gravity.db`
* SQLite
```bash
sudo hexdump -C *.db | head
sqlite3 gravity.db
```
    ```
    .tables
    .schema domainlist
    ```
    ```sql
        SELECT COUNT(*) FROM domainlist;
        SELECT id, type, domain, enabled, date_added, comment
        FROM domainlist
        LIMIT 10;
    ```
### Structure
* type
    * 0 → allow
    * 1 → deny
    * 2 → Regex Allow
    * 3 → Regex Deny

* domain: Domain name

* enabled: enabled (1) / disabled (0)

* comment: memo

* A trigger is set so that:
    * On INSERT, it automatically links to domainlist_by_group
    * On UPDATE, it updates date_modified
    * On DELETE, it removes the related entries