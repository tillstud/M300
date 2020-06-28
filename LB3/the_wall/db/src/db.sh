#!/bin/bash

# create the `data` table
mysql -uroot -pexample <<%EOF%
	use proposals;
	create table data ( seq INT PRIMARY KEY AUTO_INCREMENT, uname TEXT, proposal TEXT, created TIMESTAMP DEFAULT CURRENT_TIMESTAMP );
%EOF%
