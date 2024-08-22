FROM samagragovernance/postgres:1.0.1-pg15

ARG BARMAN_HOST

ENV BARMAN_HOST=$BARMAN_HOST

ADD config/postgresql.conf.template /etc/postgresql/postgresql.conf.template
ADD config/pg_hba.conf.template /etc/postgresql/pg_hba.conf.template

RUN apk update && \
    apk add envsubst rsync && \
    envsubst < /etc/postgresql/postgresql.conf.template > /etc/postgresql/postgresql.conf && \
    envsubst < /etc/postgresql/pg_hba.conf.template > /etc/postgresql/pg_hba.conf; 

ARG BARMAN_SSH_PUBLIC_KEY 
ARG POSTGRES_SSH_PUBLIC_KEY 
ARG POSTGRES_SSH_PRIVATE_KEY

# Install OpenSSH
RUN apk add --update --no-cache openssh openssh-keygen

# Enable SSH and configure key-based authentication
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh

# Use build argument to add the public key
RUN echo "$BARMAN_SSH_PUBLIC_KEY" > /root/.ssh/authorized_keys && chmod 600 /root/.ssh/authorized_keys

# Create the .ssh directory for the postgres user
RUN mkdir -p /var/lib/postgresql/.ssh && \
    chmod 700 /var/lib/postgresql/.ssh && \
    chown postgres:postgres /var/lib/postgresql/.ssh

# Use build argument to add the public key for the postgres user
RUN echo "$BARMAN_SSH_PUBLIC_KEY" > /var/lib/postgresql/.ssh/authorized_keys && \
    chmod 600 /var/lib/postgresql/.ssh/authorized_keys && \
    chown postgres:postgres /var/lib/postgresql/.ssh/authorized_keys

# Configure SSH daemon
RUN echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config
RUN echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config
RUN echo 'AllowUsers postgres' >> /etc/ssh/sshd_config

RUN echo "$POSTGRES_SSH_PUBLIC_KEY" > /var/lib/postgresql/.ssh/id_ed25519.pub && chmod 600 /var/lib/postgresql/.ssh/id_ed25519.pub
RUN echo "$POSTGRES_SSH_PRIVATE_KEY" > /var/lib/postgresql/.ssh/id_ed25519 && chmod 600 /var/lib/postgresql/.ssh/id_ed25519
RUN ssh-keyscan -H "$BARMAN_HOST" >> /var/lib/postgresql/.ssh/known_hosts