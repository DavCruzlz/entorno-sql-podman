#!/bin/sh
sed -i '/^host/ s/trust/scram-sha-256/' "$PGDATA/pg_hba.conf"