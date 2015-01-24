#!/bin/bash

####---- 设置软件版本 ----begin####
export nginx_version=1.7.5
export mysql_version=5.6.22
export php_version=5.6.4
export phpmyadmin_version=4.1.8

export phpmyadmin_src=phpMyAdmin-${phpmyadmin_version}-all-languages.tar.gz

export mhash_version=0.9.9.9
export libmcrypt_version=2.5.8
export mcrypt_version=2.6.8
export libiconv_version=1.14

export dl_nginx=http://www.cmzz.net/index.php/Download/index/file/nginx-${nginx_version}.tar.gz/type/Nginx
export dl_mysql=http://www.cmzz.net/index.php/Download/index/file/mysql-${mysql_version}.tar.gz/type/MySQL
export dl_mhash=http://www.cmzz.net/index.php/Download/index/file/mhash-${mhash_version}.tar.gz/type/mhash
export dl_mcrypt=http://www.cmzz.net/index.php/Download/index/file/mcrypt-${mcrypt_version}.tar.gz/type/mcrypt
export dl_libmcrypt=http://www.cmzz.net/index.php/Download/index/file/libmcrypt-${libmcrypt_version}.tar.gz/type/libmcrypt
export dl_libiconv=http://www.cmzz.net/index.php/Download/index/file/libiconv-${libiconv_version}.tar.gz/type/libiconv
export dl_php=http://www.cmzz.net/index.php/Download/index/file/php-${php_version}.tar.gz/type/php
export dl_phpmyadmin=http://www.cmzz.net/index.php/Download/index/file/${phpmyadmin_src}/type/phpMyAdmin


if [ $(id -u) != "0" ]; then
    printf "Error: 安装程序需要root权限才能运行!"
    exit 1
fi

clear

echo ""
echo "========================================================================="
echo "onekeyLNMP  "
echo "========================================================================="
echo "onekeyLNMP 是 LNMP 环境的自动化安装程序，目前只能运行于 Centos 系统 "
echo "========================================================================="
echo "Author : 吴酌 | http://wuzhuo.net"
echo "========================================================================="

sleep 5

echo ""
echo "You will install :"
echo "nginx  		: $nginx_version"
echo "php    		: $php_version"
echo "mysql  		: $mysql_version"
echo "phpmyadmin  	: $phpmyadmin_version"

read -n1 -p "确认安装请输入[y | Y] , 退出请按任意键: " yes
if [ "${yes}" != "y" ] && [ "${yes}" != "Y" ];then
   exit 1
fi

#获取开始时间
begin_time="`gawk 'BEGIN{print systime()}'`"


function update {
	clear
	echo ""
	echo "### 正在安装所需的系统组件 ###"
	sleep 3
	yum -y remove httpd*
	yum -y remove php*
	yum -y remove mysql-server mysql
	yum -y remove php-mysql

	yum -y install yum-fastestmirror
	yum -y remove httpd

	if [ -s /etc/selinux/config ]; then
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
	fi

	yum -y update
	yum -y install wget unzip gcc gcc-c++ make cmake autoconf automake openssl openssl-devel openssl-perl openssl-static zlib zlib-devel pcre pcre-devel ncurses ncurses-devel bison bison-devel curl curl-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel libxml2 libxml2-devel gd freetype freetype-devel libjpeg libjpeg-devel libpng libpng-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers libXpm t1lib t1lib-devel libxslt libxslt-devel net-snmp net-snmp-devel gdbm-devel db4-devel libXpm-devel libX11-devel gd-devel gmp-devel readline-devel libxslt-devel expat-devel xmlrpc-c xmlrpc-c-devel zlib zlib-devel openssl openssl--devel pcre pcre-devel tcl
	iptables -F
}


function user_and_dirs {
	clear
	echo ""
	echo "### 正在创建安装目录 ###"
	/usr/sbin/groupadd www
	/usr/sbin/useradd -g www www
	/usr/sbin/groupadd mysql
	/usr/sbin/useradd -g mysql mysql

	####---- make dir ----begin####
	clear
	echo ""
	echo "### 正在创建系统用户 ###"
	sleep 3
	web_dir=nginx-${nginx_version}
	php_dir=php-${php_version}

	export web_dir
	export php_dir
	export mysql_dir=mysql-${mysql_version}
	export vsftpd_dir=vsftpd-${vsftpd_version}
	export sphinx_dir=sphinx-${sphinx_version}

	mkdir -p /iwzdata
	mkdir -p /iwzdata/soft
	mkdir -p /iwzdata/LNMP

	mkdir -p /iwzdata/www
	chown www:www /iwzdata/www
	chmod 755 /iwzdata/www

	mkdir -p /iwzdata/dbdata
	chmod 755 /iwzdata/dbdata
	chown mysql:mysql /iwzdata/dbdata


	mkdir -p /iwzdata/soft/${mysql_dir}
	ln -s /iwzdata/soft/${mysql_dir} /iwzdata/soft/mysql

	mkdir -p /iwzdata/soft/${php_dir}
	ln -s /iwzdata/soft/${php_dir} /iwzdata/soft/php

	mkdir -p /iwzdata/soft/${web_dir}
	ln -s /iwzdata/soft/${web_dir} /iwzdata/soft/nginx
}


function install_nginx {
	clear
	echo ""
	echo "### 正在安装nginx ###"
	sleep 3
	cd /iwzdata/LNMP
	nginx_sf=nginx-${nginx_version}.tar.gz

	if [ ! -f "$nginx_sf" ]; then
		echo "## 开始从百源[http://cmzz.net]下载Nginx, 可能需要几分钟时间..."
		sleep 3
		#wget http://nginx.org/download/${nginx_sf}
		wget ${dl_nginx} -O ${nginx_sf}
	fi

	tar zxvf ${nginx_sf}
	cd nginx-${nginx_version}
	./configure --user=www --group=www --prefix=/iwzdata/soft/nginx --pid-path=/tmp/nginx.pid --with-http_stub_status_module --with-http_ssl_module
	make
	make install

	ln -s /iwzdata/soft/nginx/sbin/nginx /etc/init.d/nginx
	echo "/iwzdata/soft/nginx/sbin/nginx" >> /etc/rc.local
	ln -s /iwzdata/soft/nginx/conf/nginx.conf /etc/nginx.conf

	sed -i '$i include /iwzdata/soft/nginx/conf/vhosts/*.conf;' /iwzdata/soft/nginx/conf/nginx.conf
	sed -i '34,80d' /iwzdata/soft/nginx/conf/nginx.conf

	cd /iwzdata/soft/nginx/conf/
	mkdir vhosts
	cd vhosts
	touch default.conf

	chown www:www -R /iwzdata/soft/nginx/conf/vhosts
	chmod u+x -R /iwzdata/soft/nginx/conf/vhosts
	/etc/init.d/nginx
}


function install_mysql {
	clear
	echo ""
	echo "### 正在安装MySQL ###"
	sleep 3
	cd /iwzdata/LNMP
	mysql_sc=mysql-${mysql_version}.tar.gz

	if [ ! -f "$mysql_sc" ]; then
		echo "## 开始从百源[http://cmzz.net]下载MySQL, 很快很快的..."
		sleep 3
		#wget http://cdn.mysql.com/Downloads/MySQL-5.6/${mysql_sc}
		wget ${dl_mysql} -O ${mysql_sc}
	fi

	tar zxvf $mysql_sc
	cd mysql-$mysql_version
	cmake . -DCMAKE_INSTALL_PREFIX=/iwzdata/soft/mysql -DMYSQL_DATADIR=/iwzdata/dbdata -DSYSCONFDIR=/iwzdata/soft/mysql -DMYSQL_UNIX_ADDR=/tmp/mysql.sock -DMYSQL_USER=mysql -DWITH_DEBUG=0 -DMYSQL_TCP_PORT=3306 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_READLINE=1 -DWITH_SSL=yes

	make
	make install

	cp /iwzdata/soft/mysql/support-files/my-default.cnf /iwzdata/soft/mysql/my.cnf
	rm -f /etc/my.cnf
	ln -s /iwzdata/soft/mysql/my.cnf /etc/my.cnf
	ln -s /iwzdata/soft/mysql/bin/mysql* /usr/local/bin
	ln -s /iwzdata/soft/mysql/support-files/mysql.server /etc/init.d/mysqld
	chmod o+x /etc/init.d/mysqld
	/iwzdata/soft/mysql/scripts/mysql_install_db --user=mysql --basedir=/iwzdata/soft/mysql --datadir=/iwzdata/dbdata
	service mysqld start
	echo "service mysqld start" >> /etc/rc.local
}


function install_php {
	clear
	echo ""
	echo "### 正在安装php依赖组件 ###"
	sleep 3
	cd /iwzdata/LNMP/

	mhash_sc=mhash-${mhash_version}
	libmcrypt_sc=libmcrypt-${libmcrypt_version}
	mcrypt_sc=mcrypt-${mcrypt_version}
	libiconv_sc=libiconv-${libiconv_version}

	if [ ! -f "${mhash_sc}.tar.gz" ]; then
		#wget http://downloads.sourceforge.net/mhash/${mhash_sc}.tar.gz
		wget ${dl_mhash} -O ${mhash_sc}.tar.gz
	fi

	if [ ! -f "${libmcrypt_sc}.tar.gz" ]; then
		#wget http://downloads.sourceforge.net/mcrypt/${libmcrypt_sc}.tar.gz
		wget ${dl_libmcrypt} -O ${libmcrypt_sc}.tar.gz
	fi

	if [ ! -f "${mcrypt_sc}.tar.gz" ]; then
		#wget http://downloads.sourceforge.net/mcrypt/${mcrypt_sc}.tar.gz
		wget ${dl_mcrypt} -O ${mcrypt_sc}.tar.gz
	fi

	if [ ! -f "${libiconv_sc}.tar.gz" ]; then
		#wget http://ftp.gnu.org/pub/gnu/libiconv/${libiconv_sc}.tar.gz
		wget ${dl_libiconv} -O ${libiconv_sc}.tar.gz
	fi

	tar zxvf ${libiconv_sc}.tar.gz
	cd ${libiconv_sc}
	./configure --prefix=/usr
	make
	make install
	cd ..

	tar zxvf ${libmcrypt_sc}.tar.gz
	cd ${libmcrypt_sc}
	./configure --prefix=/usr
	make
	make install

	cd libltdl/
	./configure --prefix=/usr --enable-ltdl-install
	make
	make install
	cd ../..

	tar zxvf ${mhash_sc}.tar.gz
	cd ${mhash_sc}
	./configure
	make
	make install
	cd ..

	echo "/usr/local/lib" >> /etc/ld.so.conf
	echo "/usr/lib" >> /etc/ld.so.conf
	echo "/usr/lib64" >> /etc/ld.so.conf
	ldconfig

	tar zxvf ${mcrypt_sc}.tar.gz
	cd ${mcrypt_sc}
	./configure
	make
	make install

	ln -s /usr/lib64/libldap* /usr/lib/

	cd /iwzdata/LNMP
	php_sc=php-${php_version}
	if [ ! -f "${php_sc}.tar.gz" ]; then
		clear
		echo "## 开始从百源[http://cmzz.net]下载PHP, 耐心等待哦..."
		sleep 3
		#wget http://cn2.php.net/distributions/${php_sc}.tar.gz
		wget ${dl_php} -O ${php_sc}.tar.gz
	fi

	tar zxvf ${php_sc}.tar.gz
	cd ${php_sc}

	./configure --prefix=/iwzdata/soft/php --disable-fileinfo --with-config-file-path=/iwzdata/soft/php/etc --with-mysql=/iwzdata/soft/mysql --with-mysqli=/iwzdata/soft/mysql/bin/mysql_config --enable-fpm --with-ncurses --enable-soap --with-libxml-dir --with-XMLrpc --with-openssl --with-mcrypt --with-mhash --with-pcre-regex --with-sqlite3 --with-zlib --enable-bcmath --with-iconv --with-bz2 --enable-calendar --with-curl --with-cdb --enable-dom --enable-exif --enable-fileinfo --enable-filter --with-pcre-dir --enable-ftp --with-gd --with-openssl-dir --with-jpeg-dir --with-png-dir --with-zlib-dir  --with-freetype-dir --enable-gd-native-ttf --enable-gd-jis-conv --with-gettext --with-gmp --with-mhash --enable-json --enable-mbstring --disable-mbregex --disable-mbregex-backtrack --with-libmbfl --with-onig --enable-pdo --with-pdo-mysql --with-zlib-dir --with-pdo-sqlite --with-readline --enable-session --enable-shmop --enable-simplexml --enable-sockets --enable-sqlite-utf8 --enable-sysvmsg --enable-sysvsem --enable-sysvshm --enable-wddx --with-libxml-dir  --with-xsl --enable-zip --enable-mysqlnd-compression-support --with-pear --enable-pcntl –-enable-sysvmsg
	make ZEND_EXTRA_LIBS='-liconv'
	make install

	cp /iwzdata/soft/php/etc/php-fpm.conf.default /iwzdata/soft/php/etc/php-fpm.conf
	cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
	chmod o+x /etc/init.d/php-fpm
	cp php.ini-development /iwzdata/soft/php/etc/php.ini
	service php-fpm start
	echo "service php-fpm start" >> /etc/rc.local
	ln -s /iwzdata/soft/php/etc/php.ini /etc/php.ini
	ln -s /iwzdata/soft/php/etc/php-fpm.conf /etc/php-fpm.conf
}


function install_phpmyadmin {
	clear 
	echo ""
	echo "### 正在安装phpMyAdmin ###"
	sleep 3
	cd /iwzdata/LNMP
	if [ ! -f phpmyadmin.zip ];then
	  #wget http://oss.aliyuncs.com/aliyunecs/onekey/phpMyAdmin-4.1.8-all-languages.zip
	  wget ${dl_phpmyadmin} -O ${phpmyadmin_src}
	fi
	rm -rf phpMyAdmin-${phpmyadmin_version}-all-languages
	if [[ $phpmyadmin_src == *zip ]]; then 
		unzip phpMyAdmin-4.1.8-all-languages.zip
	else
		tar zxvf $phpmyadmin_src
	fi
		
	mv phpMyAdmin-4.1.8-all-languages /iwzdata/www/phpmyadmin

	chown -R www:www /iwzdata/www/phpmyadmin/
}


#创建nginx配置文件
function create_nginx_conf {
	defautl_conf=/iwzdata/soft/nginx/conf/vhosts/default.conf
	echo "server {">>$defautl_conf
	echo -e "\0011listen       80;">>$defautl_conf
	echo -e "\0011server_name localhost;">>$defautl_conf
	echo "">>$defautl_conf
	echo -e "\0011#charset koi8-r;">>$defautl_conf
	echo -e "\0011#access_log  logs/host.access.log  main;">>$defautl_conf
	echo "">>$defautl_conf
	echo -e "\0011root   /iwzdata/www;">>$defautl_conf
	echo -e "\0011location / {      ">>$defautl_conf
	echo -e "\0011\0011index  index.html index.htm index.php;">>$defautl_conf
	echo -e "\0011\0011autoindex  off;	">>$defautl_conf
	echo -e "\0011}">>$defautl_conf
	echo "">>$defautl_conf
	echo -e "\0011error_page   500 502 503 504  /50x.html;">>$defautl_conf
	echo -e "\0011location = /50x.html {">>$defautl_conf
	echo -e "\0011\0011root   html;">>$defautl_conf
	echo -e "\0011}">>$defautl_conf
	echo "">>$defautl_conf
	echo -e "\0011 location ~ \\.php(.*)\$ {">>$defautl_conf
	echo -e "\0011\0011fastcgi_pass   127.0.0.1:9000;">>$defautl_conf
	echo -e "\0011\0011fastcgi_index  index.php;">>$defautl_conf
	echo -e "\0011\0011fastcgi_split_path_info  ^((?U).+\\.php)(/?.+)\$;">>$defautl_conf
	echo -e "\0011\0011fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;">>$defautl_conf
	echo -e "\0011\0011fastcgi_param  PATH_INFO  \$fastcgi_path_info;">>$defautl_conf
	echo -e "\0011\0011fastcgi_param  PATH_TRANSLATED  \$document_root\$fastcgi_path_info;">>$defautl_conf
	echo -e "\0011\0011include        fastcgi_params;">>$defautl_conf
	echo -e "\0011}">>$defautl_conf
	echo "}">>$defautl_conf
	echo "">>$defautl_conf
}


#创建lnmp脚本文件
function create_lnmp_shell {
	lnmpfile=/bin/lnmp
	touch $lnmpfile

	echo -e '#!/bin/bash'>>$lnmpfile

	echo -e 'if [ $(id -u) != "0" ]; then'>>$lnmpfile
	echo -e '\0011printf "Error: must be root to run this script!\n"'>>$lnmpfile
	echo -e '\0011exit 1'>>$lnmpfile
	echo -e 'fi'>>$lnmpfile

	echo -e 'function_start()'>>$lnmpfile
	echo -e '{'>>$lnmpfile
	echo -e '\0011printf "Starting onekeyLNMP...\n"'>>$lnmpfile
	echo -e '\0011/etc/init.d/nginx '>>$lnmpfile
	echo -e '\0011/etc/init.d/php-fpm start'>>$lnmpfile
	echo -e '\0011/etc/init.d/mysqld start'>>$lnmpfile
	echo -e '}'>>$lnmpfile

	echo -e 'function_stop()'>>$lnmpfile
	echo -e '{'>>$lnmpfile
	echo -e '\0011printf "Stoping onekeyLNMP...\n"'>>$lnmpfile
	echo -e '\0011/etc/init.d/nginx -s stop'>>$lnmpfile
	echo -e '\0011/etc/init.d/php-fpm stop'>>$lnmpfile
	echo -e '\0011/etc/init.d/mysqld stop'>>$lnmpfile
	echo -e '}'>>$lnmpfile

	echo -e 'function_reload()'>>$lnmpfile
	echo -e '{'>>$lnmpfile
	echo -e '\0011printf \"Reload onekeyLNMP...\n\"'>>$lnmpfile
	echo -e '\0011/etc/init.d/nginx -s reload'>>$lnmpfile
	echo -e '\0011/etc/init.d/php-fpm reload'>>$lnmpfile
	echo -e '\0011/etc/init.d/mysqld reload'>>$lnmpfile
	echo -e '}'>>$lnmpfile

	echo -e 'case "$1" in'>>$lnmpfile
	echo -e '\0011start)'>>$lnmpfile
	echo -e '\0011\0011function_start'>>$lnmpfile
	echo -e '\0011\0011;;'>>$lnmpfile
	echo -e '\0011stop)'>>$lnmpfile
	echo -e '\0011\0011function_stop'>>$lnmpfile
	echo -e '\0011\0011;;'>>$lnmpfile
	echo -e '\0011restart)'>>$lnmpfile
	echo -e '\0011\0011function_stop'>>$lnmpfile
	echo -e '\0011\0011function_start'>>$lnmpfile
	echo -e '\0011\0011;;'>>$lnmpfile
	echo -e '\0011reload)'>>$lnmpfile
	echo -e '\0011\0011function_reload'>>$lnmpfile
	echo -e '\0011\0011;;'>>$lnmpfile
	echo -e '\0011*)'>>$lnmpfile
	echo -e '\0011\0011printf "Usage: /root/lnmp {start|stop|reload|restart}\n"'>>$lnmpfile
	echo -e 'esac'>>$lnmpfile
	echo -e 'exit'>>$lnmpfile

	chmod 777 $lnmpfile
}


#计算脚本用时
function end_time {
	#获取脚本结整时间
	usetime=`gawk 'BEGIN{print "" systime()-0'$begin_time' "";}'`
	let us=$usetime%60
	let um=$usetime/60
	let uh=$usetime/3600

	usetimestr=""
	if [ $uh -gt 0 ]; then
		usetimestr="${uh} 小时 "
	fi
	if [ $um -gt 0 ]; then
		usetimestr="$usetimestr ${um} 分 "
	fi
	if [ $us -gt 0 ]; then
		usetimestr="$usetimestr ${us} 秒"
	fi
}	


#导入环境变量
function export_env {
	echo "export PATH=$PATH:/iwzdata/soft/mysql/bin:/iwzdata/soft/nginx/sbin:/iwzdata/soft/php/sbin:/iwzdata/soft/php/bin" >> /etc/profile
	export PATH=$PATH:/iwzdata/soft/mysql/bin:/iwzdata/soft/nginx/sbin:/iwzdata/soft/php/sbin:/iwzdata/soft/php/bin
}


#安装安成
function finsh_info {
	clear
	echo "### Done ################################################################"
	echo "恭喜！onekeyLNMP 自动安装完成，耗时 ${usetimestr}"
	echo "-------------------------------------------------------------------------"
	echo ""
	echo "软件的安装目录:"
	echo "mysql 		:   /iwzdata/soft/mysql"
	echo "php 		:   /iwzdata/soft/php"
	echo "nginx 		:   /iwzdata/soft/nginx"
	echo ""
	echo "网站根目录	:   /iwzdata/www"
	echo "phpmyadmin  	:   /iwzdata/www/phpmyadmin"
	echo ""
	echo "-------------------------------------------------------------------------"
	echo ""
	echo "默认的MySQL root用户密码为空，请及时修改密码"
	echo "###"
}

####################################################################################
#执行安装
update
user_and_dirs

install_nginx
install_mysql
install_php
install_phpmyadmin

create_nginx_conf
create_lnmp_shell

export_var

end_time
finsh_info