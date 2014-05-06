FROM ubuntu:14.04
MAINTAINER mick@twomeylee.name

# Based on http://docs.docker.io/examples/postgresql_service/

RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/postgresql.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8

RUN apt-get update && \
    apt-get install -y -q \
    libpq-dev \
    postgresql-9.3 \
    postgresql-9.3-postgis-2.1 \
    postgresql-client-9.3 \
    postgresql-contrib-9.3 \
    postgresql-server-dev-9.3 \
    && apt-get autoclean \
    && apt-get clean

EXPOSE 5432

RUN mkdir -p /postgresql && chown postgres /postgresql

USER postgres

RUN date > /tmp/pw.txt && \
    /usr/lib/postgresql/9.3/bin/initdb --auth-host=md5 --auth-local=trust --pgdata=/postgresql/data --xlogdir=/postgresql/xlog --encoding=UTF-8 --username=postgres --pwfile=/tmp/pw.txt && \
    rm /tmp/pw.txt && \
    echo "host    all    all    0.0.0.0/0    md5" >> /postgresql/data/pg_hba.conf && \
    /usr/lib/postgresql/9.3/bin/pg_ctl start -D /postgresql/data -w && \
    psql --command "CREATE USER docker WITH SUPERUSER PASSWORD 'docker';" && \
    createdb -O docker docker && \
    psql -d docker --command "CREATE EXTENSION fuzzystrmatch;" && \
    psql -d docker --command "CREATE EXTENSION postgis;" && \
    psql -d docker --command "CREATE EXTENSION postgis_topology;" && \
    psql -d docker --command "CREATE EXTENSION postgis_tiger_geocoder;" && \
    /usr/lib/postgresql/9.3/bin/pg_ctl stop -D /postgresql/data -w

VOLUME  ["/postgresql/log", "/postgresql/data", "/postgresql/xlog"]

CMD ["-D", "/postgresql/data", "-h", "0.0.0.0", "-p", "5432"]
ENTRYPOINT ["/usr/lib/postgresql/9.3/bin/postgres"]
