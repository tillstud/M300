#!/bin/bash

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
