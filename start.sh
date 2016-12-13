#!/bin/sh

ROOT_PASS=password
USER_NAME=test
USER_PASS=testpass

__initialize() {
	echo "initialize..."
	sleep 3

	mysql_install_db
	chown -R mysql:mysql /var/lib/mysql
	/usr/bin/mysqld_safe &
	sleep 3
	# check status
	service mysqld status
	sleep 3
}

__exec_query() {
    MYSQL_PWD=${ROOT_PASS} /usr/bin/mysql -uroot -e "$1"
}
__create_user() {
    __exec_query "CREATE USER '$1'@'localhost' IDENTIFIED BY '$2';"
	__exec_query "CREATE USER '$1'@'%' IDENTIFIED BY '$2';"
}

__create_database() {
	__exec_query "CREATE DATABASE $1 CHARACTER SET utf8;"
	__exec_query "GRANT ALL PRIVILEGES ON \`$1\`.* TO '$2'@'localhost';"
	__exec_query "GRANT ALL PRIVILEGES ON \`$1\`.* TO '$2'@'%';"
}

__setup() {
	echo "setup database."
	mysqladmin -uroot password ${ROOT_PASS}
	sleep 3

	__create_user ${USER_NAME} ${USER_PASS}
	__create_database test_db ${USER_NAME}

	echo "======== db ========"
	__exec_query "show databases;"
	echo "===================="

	echo "mysql setup finish. shutdown mysql..."
	mysqladmin shutdown -uroot -p${ROOT_PASS}
	service mysqld status
	sleep 3
}

# check initialize and start
if [ -z "`ls /var/lib/mysql`" ]; then
	__initialize
	__setup
	/usr/bin/mysqld_safe
else
	echo "already initialized. mysql start...."
	/usr/bin/mysqld_safe
fi