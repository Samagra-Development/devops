# Steps to run after the db container is started

1. Run `docker exec db /usr/sbin/sshd`

# Steps to setup barman

1. Run `make setup-barman`

# Useful Commands

`barman check mydb` to check the status of mydb
`barman backup mydb` to backup mydb
`barman switch-xlog --force --archive mydb` to fix wal issues