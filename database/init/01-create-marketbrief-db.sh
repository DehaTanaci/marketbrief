#!/bin/sh
# Runs once, on the very first start of an empty Postgres volume.
# n8n keeps its own data in $POSTGRES_DB; the bot's tables live in a separate "marketbrief" database.
set -e
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -c "CREATE DATABASE marketbrief"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname marketbrief -f /schema/schema.sql
