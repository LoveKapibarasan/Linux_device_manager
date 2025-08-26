# 1. Install RabbitMQ
sudo pacman -S rabbitmq erlang
sudo systemctl enable --now rabbitmq
# Optional: Web UI
sudo rabbitmq-plugins enable rabbitmq_management

# 2. postgis
sudo systemctl enable postgresql --now
sudo pacman -S postgis
sudo -iu postgres
# -i= simulate an initial login
# -U= run as a UNIX user instead of root
psql -d template1
# Modify template 1 
# psql = Open PostgreSQL interactive table(Default: Normal shell )
# -d = database name
# Whatever you create a database, your database is copied from template1
# If you do not want, use template0.
CREATE EXTENSION postgis;
CREATE EXTENSION postgis_topology;
