#!/bin/sh
# --------------------------------------------------------------------------------------------------
# Startup script for all systems. Initializes Postgres server and launches the Node API app. Will be
# executed when the container starts.
# --------------------------------------------------------------------------------------------------

set -xeu

/etc/init.d/postgresql start
/bin/node app.js
