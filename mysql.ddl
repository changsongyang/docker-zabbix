create database zabbix character set utf8 collate utf8_bin;
grant all privileges on zabbix.* to zabbix@'%';
flush privileges;
