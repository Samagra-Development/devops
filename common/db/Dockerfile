FROM samagragovernance/postgres:1.0.1-pg15

ARG ENABLE_BARMAN
ARG ID_RSA
ARG ID_RSA_PUB 
ARG BARMAN_SERVER

ADD config/postgresql.conf.template /etc/postgresql/postgresql.conf.template
ADD config/pg_hba.conf.template /etc/postgresql/pg_hba.conf.template

RUN apk update && \
    apk add envsubst && \
    envsubst < /etc/postgresql/postgresql.conf.template > /etc/postgresql/postgresql.conf && \
    envsubst < /etc/postgresql/pg_hba.conf.template > /etc/postgresql/pg_hba.conf;
 
RUN if [ "$ENABLE_BARMAN" = "true" ]; then \
    apk update && \
    apk add openrc openssh-server openssh rsync && \
    mkdir -p /run/openrc && \
    touch /run/openrc/softlevel && \
    ssh-keygen -A && \
    echo -e "PasswordAuthentication no" >> /etc/ssh/sshd_config && \
    mkdir -p /var/lib/postgresql/.ssh && \
    echo "" > /var/lib/postgresql/.ssh/known_hosts && \
    echo "$ID_RSA" | base64 -d > /var/lib/postgresql/.ssh/id_rsa && \
    echo "$ID_RSA_PUB" | base64 -d  > /var/lib/postgresql/.ssh/id_rsa.pub && \
    chmod 0600 /var/lib/postgresql/.ssh/id_rsa && \
    echo -e "Host *\n\tStrictHostKeyChecking no" > /var/lib/postgresql/.ssh/config && \
    passwd -u postgres && \
    chown -R postgres:postgres /var/lib/postgresql/.ssh; \
fi

EXPOSE 22
EXPOSE 5432


