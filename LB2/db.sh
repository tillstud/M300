#!/bin/bash
#
#	Datenbank installieren und Konfigurieren
#

# root Password setzen, damit kein Dialog erscheint und die Installation haengt!
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password S3cr3tp4ssw0rd'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password S3cr3tp4ssw0rd'

# Installation
sudo apt-get install -y mysql-server ufw

# MySQL Port oeffnen
# Datei /etc/mysql/mysql.conf.d/mysqld.cnf mittels sed so abaendern, dass MySQL Port fuer alle offen ist
sudo sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf 

# User fuer Remote Zugriff einrichten - aber nur fuer Host web 192.168.55.101
mysql -uroot -pS3cr3tp4ssw0rd <<%EOF%
	CREATE USER 'root'@'192.168.55.101' IDENTIFIED BY 'admin';
	GRANT ALL PRIVILEGES ON *.* TO 'root'@'192.168.55.101';
	FLUSH PRIVILEGES;
%EOF%

# Datenbank und User fuer IoT Daten anlegen 
mysql -uroot -pS3cr3tp4ssw0rd <<%EOF%
	create database if not exists proposals;
	flush privileges;
	use proposals;
	create table data ( seq INT PRIMARY KEY AUTO_INCREMENT, uname TEXT, proposal TEXT, created TIMESTAMP DEFAULT CURRENT_TIMESTAMP );
%EOF%

# Restart fuer Konfigurationsaenderung
sudo service mysql restart

# Monitoring
sudo cp /vagrant/cron.root.db01 /var/spool/cron/crontabs/root && sudo chmod 600 /var/spool/cron/crontabs/root
sudo service cron reload

# Firewall 
sudo ufw allow 22/tcp
sudo ufw allow from 192.168.55.101 to any port 3306
sudo ufw -f enable
