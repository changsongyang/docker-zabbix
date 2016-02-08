<?php
// use local db if not set
$ZABBIX_DB = getenv("ZABBIX_DB");
empty($ZABBIX_DB) && $ZABBIX_DB = "localhost";

// Zabbix GUI configuration file.
global $DB;

$DB['TYPE']			= 'MYSQL';
$DB['SERVER']			= $ZABBIX_DB;
$DB['PORT']			= '0';
$DB['DATABASE']			= 'zabbix';
$DB['USER']			= 'zabbix';
$DB['PASSWORD']			= '';
// Schema name. Used for IBM DB2 and PostgreSQL.
$DB['SCHEMA']			= '';

$ZBX_SERVER			= 'localhost';
$ZBX_SERVER_PORT		= '10051';
$ZBX_SERVER_NAME		= '';

$IMAGE_FORMAT_DEFAULT	= IMAGE_FORMAT_PNG;
?>
