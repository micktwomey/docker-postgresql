FROM ubuntu:13.10
MAINTAINER mick@twomeylee.name

# Based on http://docs.docker.io/examples/postgresql_service/

RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/postgresql.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8

RUN apt-get update && \
    apt-get install -y -q \
    libpq-dev \
    postgresql-9.3 \
    postgresql-9.3-postgis \
    postgresql-client-9.3 \
    postgresql-contrib-9.3 \
    postgresql-server-dev-9.3

USER postgres

RUN /etc/init.d/postgresql start && \
    psql --command "CREATE USER docker WITH SUPERUSER PASSWORD 'docker';" && \
    psql --command "CREATE EXTENSION adminpack;" && \
    createdb -O docker docker

RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.3/main/pg_hba.conf

RUN echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf

EXPOSE 5432

VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

CMD ["-D", "/var/lib/postgresql/9.3/main", "-c", "config_file=/etc/postgresql/9.3/main/postgresql.conf"]
ENTRYPOINT ["/usr/lib/postgresql/9.3/bin/postgres"]
