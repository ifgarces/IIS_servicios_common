# --------------------------------------------------------------------------------------------------
# Dockerfile for Node.js and Postgres.
# --------------------------------------------------------------------------------------------------

ARG UBUNTU_VERSION
FROM ubuntu:${UBUNTU_VERSION}

WORKDIR /srcei

# Installing PostgreSQL 13 server
RUN apt-get update --quiet && apt-get install --quiet -y \
        wget gnupg software-properties-common tree \
    && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > \
        /etc/apt/sources.list.d/pgdg.list \
    && apt-get update --quiet && apt-get install --quiet -y postgresql-13

# Installing base Node and NPM
RUN apt-get update --quiet && apt-get install --quiet -y nodejs npm

# Creating Postgres database for root user
RUN /etc/init.d/postgresql start \
    && su - postgres -c "psql --command=\"CREATE USER root WITH PASSWORD 'postgres';\"" \
    && su - postgres -c "psql --command=\"CREATE DATABASE root OWNER root;\""

# Copying database files
COPY ../database/data.sql .
COPY ../database/tables.sql .

# Copying Node.js project files
COPY ../models models
COPY ../controllers controllers
COPY ../public public
COPY ../routes routes
COPY ../.env .
COPY ../app.js .
COPY ../package.json .
COPY ../package-lock.json .

# Installing Node dependencies
RUN npm install

# Populating database
RUN /etc/init.d/postgresql start \
    && psql --file="tables.sql" \
    && psql --file="data.sql"

# Exposing API port
ARG API_PORT
EXPOSE ${API_PORT}

# Command for executing the API server and outputting to stdout
CMD [ "/bin/node", "app.js" ]
