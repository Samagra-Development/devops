#!/bin/sh

# Start PostgreSQL
pg_ctl -D "$PGDATA" -o "-c archive_mode=on -c archive_command='test ! -f /var/lib/postgresql/archive/%f && cp %p /var/lib/postgresql/archive/%f'" start

# Start SSH
exec /usr/sbin/sshd -D -e
