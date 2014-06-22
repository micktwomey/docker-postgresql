#!/bin/sh
#
# Create a postgresql instance
#
# If there is already an instance this just quits out (exit 0)
#

set -eu

if [ -f /postgresql/data/pg_hba.conf ]; then
    echo "Instance already exists in /postgresql/data, exiting";
    exit 0;
fi

chown -R postgres /postgresql
date > /tmp/pw.txt
su postgres -c "/usr/lib/postgresql/9.3/bin/initdb --auth-host=md5 --auth-local=trust --pgdata=/postgresql/data --xlogdir=/postgresql/xlog --encoding=UTF-8 --username=postgres --pwfile=/tmp/pw.txt"
rm /tmp/pw.txt

echo "host    all    all    0.0.0.0/0    md5" >> /postgresql/data/pg_hba.conf

/usr/lib/postgresql/9.3/bin/pg_ctl start -D /postgresql/data -w
psql --command "CREATE USER docker WITH SUPERUSER PASSWORD 'docker';"
createdb -O docker docker
psql -d docker --command "CREATE EXTENSION fuzzystrmatch;"
psql -d docker --command "CREATE EXTENSION postgis;"
psql -d docker --command "CREATE EXTENSION postgis_topology;"
psql -d docker --command "CREATE EXTENSION postgis_tiger_geocoder;"
/usr/lib/postgresql/9.3/bin/pg_ctl stop -D /postgresql/data -w
