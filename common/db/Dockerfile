FROM samagragovernance/postgres:1.0.1-pg15

ARG ENABLE_BARMAN
ARG DB_SSH_PRIVATE_KEY
ARG DB_SSH_PUBLIC_KEY 
ARG BARMAN_HOST

ENV BARMAN_HOST=$BARMAN_HOST

# Check if ENABLE_BARMAN is set to true, and if so, ensure other arguments are provided
# Check if ENABLE_BARMAN is set to true, and if so, ensure other arguments are provided
RUN if [ "$ENABLE_BARMAN" = "true" ]; then \
        : "${DB_SSH_PRIVATE_KEY:?DB_SSH_PRIVATE_KEY is not set}"; \
        : "${DB_SSH_PUBLIC_KEY:?DB_SSH_PUBLIC_KEY is not set}"; \
        : "${BARMAN_HOST:?BARMAN_HOST is not set}"; \
    fi

ADD config/postgresql.conf.template /etc/postgresql/postgresql.conf.template
ADD config/pg_hba.conf.template /etc/postgresql/pg_hba.conf.template

RUN if [ "$ENABLE_BARMAN" = "true" ]; then \
    apk update && \
    apk add envsubst && \
    envsubst < /etc/postgresql/postgresql.conf.template > /etc/postgresql/postgresql.conf && \
    envsubst < /etc/postgresql/pg_hba.conf.template > /etc/postgresql/pg_hba.conf; \
    else \
     ln -s /var/lib/postgresql/data/pg_hba.conf /etc/postgresql/pg_hba.conf &\
     ln -s /var/lib/postgresql/data/postgresql.conf /etc/postgresql/postgresql.conf; \
fi

     

RUN if [ "$ENABLE_BARMAN" = "true" ]; then \
    apk update && \
    apk add openrc openssh-server openssh rsync && \
    mkdir -p /run/openrc && \
    touch /run/openrc/softlevel && \
    ssh-keygen -A && \
    echo -e "PasswordAuthentication no" >> /etc/ssh/sshd_config && \
    mkdir -p /var/lib/postgresql/.ssh && \
    echo "" > /var/lib/postgresql/.ssh/known_hosts && \
    echo "$DB_SSH_PRIVATE_KEY" | base64 -d > /var/lib/postgresql/.ssh/id_rsa && \
    echo "$DB_SSH_PUBLIC_KEY" | base64 -d  > /var/lib/postgresql/.ssh/id_rsa.pub && \
    chmod 0600 /var/lib/postgresql/.ssh/id_rsa && \
    echo -e "Host *\n\tStrictHostKeyChecking no" > /var/lib/postgresql/.ssh/config && \
    passwd -u postgres && \
    chown -R postgres:postgres /var/lib/postgresql/.ssh; \
fi

EXPOSE 22
EXPOSE 5432


