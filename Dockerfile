FROM ubuntu:14.04
 
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN locale-gen en_US en_US.UTF-8
ENV LANG en_US.UTF-8
ENV TERM xterm
RUN echo "export PS1='\e[1;31m\]\u@\h:\w\\$\[\e[0m\] '" >> /root/.bashrc

#Runit
RUN apt-get install -y runit 
CMD export > /etc/envvars && /usr/sbin/runsvdir-start
RUN echo 'export > /etc/envvars' >> /root/.bashrc

#Utilities
RUN apt-get install -y vim less net-tools inetutils-ping wget curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common jq psmisc

RUN apt-get install -y build-essential

RUN apt-get install -y mysql-server mysql-client
RUN apt-get install -y libmysqlclient-dev
RUN apt-get install -y libxml2-dev
RUN apt-get install -y libsnmp-dev 
RUN apt-get install -y libcurl4-openssl-dev 

#Nginx
RUN apt-get install -y nginx

#PHP
RUN apt-get install -y php5-dev
RUN apt-get install -y php5-gd php5-json php5-mysql php5-curl
RUN apt-get install -y php5-intl php5-mcrypt php5-imagick
RUN apt-get install -y php5-fpm
#RUN sed -i "s|;cgi.fix_pathinfo=1|cgi.fix_pathinfo=0|" /etc/php5/fpm/php.ini
#RUN sed -i "s|upload_max_filesize = 2M|upload_max_filesize = 16G|" /etc/php5/fpm/php.ini
#RUN sed -i "s|post_max_size = 8M|post_max_size = 16M|" /etc/php5/fpm/php.ini
#RUN sed -i "s|output_buffering = 4096|output_buffering = Off|" /etc/php5/fpm/php.ini
#RUN sed -i "s|memory_limit = 128M|memory_limit = 512M|" /etc/php5/fpm/php.ini
#RUN sed -i "s|max_execution_time = .*|max_execution_time = 300|" /etc/php5/fpm/php.ini
#RUN sed -i "s|;pm.max_requests = 500|pm.max_requests = 500|" /etc/php5/fpm/pool.d/www.conf

#Zabbix
RUN wget -O - http://downloads.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/3.0.0/zabbix-3.0.0.tar.gz | tar zx
RUN mv /zabbix* /zabbix

RUN cd /zabbix && \
    ./configure --enable-server --enable-agent --with-mysql --enable-ipv6 --with-net-snmp --with-libcurl --with-libxml2 && \
    make -j8 && \
    make install 

RUN groupadd zabbix && \
    useradd -g zabbix zabbix

RUN mkdir -p /var/www && \
    cp -a /zabbix/frontends/php/* /var/www

#Sensors
RUN apt-get install -y lm-sensors
RUN apt-get install -y fping

#Config
#COPY zabbix.conf.php /var/www/conf/
RUN  cp /var/www/conf/zabbix.conf.php.example /var/www/conf/zabbix.conf.php
COPY default /etc/nginx/sites-enabled/ 
COPY php.ini /etc/php5/fpm/php.ini
COPY zabbix_server.conf /usr/local/etc/

#MySql
COPY mysql.ddl /
RUN mysqld_safe & mysqladmin --wait=5 ping && \
    mysql < mysql.ddl && \
    cd /zabbix/database/mysql && \
    mysql -uzabbix zabbix < schema.sql && \
    mysql -uzabbix zabbix < images.sql && \
    mysql -uzabbix zabbix < data.sql && \
    mysqladmin shutdown

#Add runit services
COPY sv /etc/service 

