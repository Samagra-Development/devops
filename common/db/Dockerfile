FROM samagragovernance/postgres:1.0.1-pg15

# Install OpenSSH
RUN apk add --update --no-cache openssh openssh-keygen

RUN ssh-keygen -A

# Verify that the host keys exist
RUN ls -l /etc/ssh/ssh_host_*

# Enable SSH and configure key-based authentication
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh

# Use build argument to add the public key
ARG DB_SSH_PUBLIC_KEY
RUN echo "$DB_SSH_PUBLIC_KEY" > /root/.ssh/authorized_keys && chmod 600 /root/.ssh/authorized_keys

# Create the .ssh directory for the postgres user
RUN mkdir -p /var/lib/postgresql/.ssh && \
    chmod 700 /var/lib/postgresql/.ssh && \
    chown postgres:postgres /var/lib/postgresql/.ssh

# Use build argument to add the public key for the postgres user
RUN echo "$DB_SSH_PUBLIC_KEY" > /var/lib/postgresql/.ssh/authorized_keys && \
    chmod 600 /var/lib/postgresql/.ssh/authorized_keys && \
    chown postgres:postgres /var/lib/postgresql/.ssh/authorized_keys


# Configure SSH daemon
RUN echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config
RUN echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config
RUN echo 'AllowUsers postgres' >> /etc/ssh/sshd_config

RUN chown -R postgres:postgres /etc/ssh

# Set up WAL archive directory
RUN mkdir -p /var/lib/postgresql/archive && chown postgres:postgres /var/lib/postgresql/archive

USER postgres

ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 22
COPY entrypoint.sh /