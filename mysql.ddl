create database zabbix character set utf8 collate utf8_bin;
create user zabbix@'%';
grant all privileges on zabbix.* to zabbix@'%';
flush privileges;
