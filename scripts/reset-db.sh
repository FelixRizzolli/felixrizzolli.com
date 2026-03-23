PGPASSWORD=supersecret-password psql -h localhost -p 5432 -U postgres -d postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='payload' AND pid <> pg_backend_pid();" && \
PGPASSWORD=supersecret-password psql -h localhost -p 5432 -U postgres -d postgres -c "DROP DATABASE IF EXISTS payload;" && \
PGPASSWORD=supersecret-password psql -h localhost -p 5432 -U postgres -d postgres -c "CREATE DATABASE payload OWNER postgres;" && \
# PGPASSWORD=supersecret-password psql -h localhost -p 5432 -U postgres -d payload -f /workspace/.devcontainer/data/payload.sql && \
PGPASSWORD=supersecret-password psql -h localhost -p 5432 -U postgres -d payload -c '\dt public.*'