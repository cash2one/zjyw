#!/bin/sh

#########################################################################################
required_locked_user="listen gdm webserved nobody nobody4 noaccess bin sys adm uucp lp nuucp hpdb www daemon shutdown halt news operator games gopher"
passwd_DOCS="/etc/passwd"
shadow_DOCS="/etc/shadow"
group_DOCS="/etc/group"
su_DOCS="/etc/pam.d/su"
logindefs_DOCS="/etc/login.defs"
vsftp_DAEMON_LOCS="/etc /etc/vsftpd"
PAM_LOCS="password-auth system-auth common-auth common-account"
syslogconfs_LOCS="/etc/syslog.conf /etc/rsyslog.conf /etc/rsyslog.d/50-default.conf"
syslog_LOCS="/var/log/boot.log /var/log/secure /var/log/messages /var/log/cron /var/log/spooler /var/log/maillog /var/log/auth.log /var/log/syslog /var/log/cron.log /var/log/daemon.log /var/log/kern.log /var/log/lpr.log /var/log/mail.log /var/log/user.log"
login_LOCS="/etc/pam.d/login"
SSH_DAEMON_CONFIG="/etc/ssh/sshd_config"
require_stop_service="daytime-dgram daytime-stream time-dgram time-stream echo-dgram echo-stream discard-dgram discard-stream chargen-dgram chargen-stream sendmail ntalk ident printer bootps tftp kshell klogin lpd nfs nfslock ypbind"
bannerconfig_LOCS="/etc/issue /etc/issue.net"
BlackUser_LOCS="/etc/vsftpd/ftpusers /etc/ftpusers"
profile_LOCS="/etc/profile"
danger_file=".rhosts .netrc hosts.equiv"
MYSQL_CONFIG_DOCS="/etc/my.cnf"
apache_CONFIG_DOCS="/etc/httpd/conf/httpd.conf"

#########################################################################################
nocheck_reason=(
                 "主机当前用户没有读文件的权限:"
                 "文件不存在:"
                 "主机当前环境不支持命令:"
                 "服务未运行:"
                 "其他原因"
                )
reason=""
check_status=""
db_type=""
middleware_type=""
ORACLE_LISTENER_DIRECTORY=""
ORACLE_SQLNET_DIRECTORY=""
tom_users_CONFIG=""
tom_server_CONFIG=""
tom_web_CONFIG=""
weblogic_config_xml=""
weblogic_config_xml=""
weblogic_web_xml=""
weblogic_xml=""
weblogic_registry_xml=""
WEBLOGIC_CONFIG_reason=""
WEBLOGIC_CONFIG_check="CHECK"
WEBLOGIC_WEB_reason=""
WEBLOGIC_WEB_check="CHECK"
WEBLOGIC_reason=""
WEBLOGIC_check="CHECK"
tom_users_reason=""
tom_users_check="CHECK"
tom_server_reason=""
tom_server_check="CHECK"
tom_web_reason=""
tom_web_check="CHECK"
nginx_config_reason=""
nginx_config_check="CHECK"
os_username_unique="TRUE"
unrelated_user_unlock=""
unrelated_user_lock="TRUE" 
etc_passwd_permission="FALSE"
etc_shadow_permission="FALSE"
etc_group_permission="FALSE"
pam_prohibit_nowheel_group_su_root="FALSE"
check_user_dir_default_accesss_permission="FALSE"
restrict_ftp_login_dir="FALSE"
password_min_length="FALSE"
letter_classification="FALSE"
password_expire="FALSE"
syslog_rsyslog_syslogn_secure="FALSE"
var_log_other_unwritable="TRUE"
syslog_rsyslog_syslogn_cron="FALSE"
syslog_rsyslog_syslogn_remotetrans="FALSE"
root_login_telnet_forbidden="FALSE"
root_login_ssh_forbidden="FALSE"
ip_ssh_protocol="FALSE"
ip_telnet_protocol_forbidden="TRUE"
sshd_config_secure="FALSE"
SYSTEM_BANNER="TRUE"
forbid_root_login_vsftp="FALSE"
forbid_anonymous_vsftpd_login="FALSE"
set_terminal_timeout="FALSE"
report_content=""
var_log_other_writable=""
unnessary_service_stop="TRUE"
unnessary_service_nostop=""
danger_file_not_exist="TRUE"
danger_file_list=""
nException="FALSE"
noroot_run_mysqld="FALSE"
config_log_files_mysqld="FALSE"
only_oracle_belong_dba="FALSE"
set_passwd_for_listener_ora="FALSE"
config_expire_time_ora="FALSE"
config_whitelist_based_IP_ora="FALSE"
config_encryption_ora="FALSE"
noroot_run_nginx="TRUE"
only_vist_specific_dir_ngn="TRUE"
error_access_log_ngn="TRUE"
error_page_redir_ngn="TRUE"
forbid_file_list_when_indexhtml_not_exitst_ngn="TRUE"
anti_DOS_attack_ngn="TRUE"
sensitive_information_hidden_ngn="TRUE"
noroot_run_apache="FALSE"
only_vist_specific_dir_apa="FALSE"
error_access_log_apa="FALSE"
error_page_redir_apa="FALSE"
forbid_file_list_when_indexhtml_not_exitst_apa="TRUE"
anti_DOS_attack_apa="FALSE"
sensitive_information_hidden_apa="FALSE"
weblogic_admin_not_root="TRUE"
weblogic_password_long_enough="TRUE" 
weblogic_letter_classification="TRUE"
weblogic_log_config="TRUE"
weblogic_max_open_socket_count="TRUE" 
weblogic_send_server_header_forbidden="TRUE" 
weblogic_login_timeout_millis="TRUE" 
weblogic_error_page="TRUE"
weblogic_index_directory_forbidden="TRUE"
tom_password_long_enough="TRUE"
tom_password_complex_enough="TRUE"
tom_no_null_username="TRUE"
tom_username_unique="TRUE"
tom_error_page="TRUE"
tom_log_config="TRUE"
tom_connection_timeout="TRUE"
forbid_list_tomcat_file="TRUE"
 
#########################################################################################
for I in ${vsftp_DAEMON_LOCS}; do
 if [ -f "${I}/vsftpd.conf" ]; then
    vsftp_DAEMON_CONFIG="${I}/vsftpd.conf"
 fi
done

for I in ${syslogconfs_LOCS}; do
 if [ -f "${I}" ]; then
    SYSLOG_CONFIG="${I}" 
 fi
done

for I in ${BlackUser_LOCS}; do
 if [ -f "${I}" ]; then
   BlackUser_list="${I}"
 fi
done


file_check()
{
 nException=FALSE
 reason=""
 check_status="CHECK"
 str=$2
 str=`echo ${str%,}`
 if [ $1 -eq 0 ]; then
  check_status="NOCHECK"
  reason="$reason${nocheck_reason[3]}$4;"
 elif [ ! -f "${str}" -o -z "${str}" ]; then
  check_status="NOCHECK"
  reason="$reason${nocheck_reason[1]}$3;"
 else
  trap "nException=TRUE" ERR
  cat $str >/dev/null 2>/dev/null
  if [ $nException == "TRUE" ]; then
   if [ ! -r "$str" ]; then
    check_status="NOCHECK"
    reason="$reason${nocheck_reason[0]}$str;"
   else
    check_status="NOCHECK"
    reason="$reason${nocheck_reason[4]};"
   fi
  fi
  nException=FALSE
  trap " " ERR
 fi
}

command_check()
{
  nException=FALSE
  reason=""
  check_status="CHECK"
  str="$1"
  trap "nException=TRUE" ERR
  $str >/dev/null 2>/dev/null
  if [ $nException == "TRUE" ]; then
    check_status="NOCHECK"
    reason=${nocheck_reason[2]}
  fi
  nException=FALSE
  trap " " ERR
}

all_nginx_server_module()
{ 
  sed '/#/d' $1 >/tmp/nginx.conf
  nginx_server_info=""
  nginx_server_info=`sed -n "
  /server\s*{/{
  H
  :loop
  n;H
  /}/{
  s/}/end-/;H
  s/end-//;x
  p
  /server/b
  }
  /{/!b loop
  :loop1
  n;H
  /}/!b loop1
  b loop
  }
  " /tmp/nginx.conf`
  rm -f /tmp/nginx.conf
}

nginx_http_no_server()
{
  sed '/#/d' $1 >/tmp/nginx.conf
  nginx_http_no_server=""
  nginx_http_no_server=`sed -n "
  /http\s*{/{
  H
  :loop2
  n
  /server\s*{/{
  :loop
  n
  /}/{
  b loop2
  }
  /{/!b loop
  :loop1
  n
  /}/!b loop1
  b loop
  }
  /server\s*{/! H
  /}/{
  s/}/end-/;H
  s/end-//;x
  p
  }
  b loop2
  }
  " /tmp/nginx.conf`
  rm -f /tmp/nginx.conf
}

nginx_server_no_location()
{ 
  sed '/#/d' $1 >/tmp/nginx.conf
  nginx_server_no_location=""
  nginx_server_no_location=`sed -n "
  /server\s*{/{
  H
  :loop
  n
  /}/{
  H
  s/}/end-/;H
  s/end-//;x
  p
  /server/b
  }
  /{/!{
  H
  b loop
  }
  :loop1
  n;
  /}/!b loop1
  b loop
  }
  " /tmp/nginx.conf`
  rm -f /tmp/nginx.conf
}

all_nginx_http_module()
{
  sed '/#/d' $1 >/tmp/nginx.conf
  nginx_http_info=""
  nginx_http_info=`sed -n "
  /http\s*{/{
  H
  :loop2
  n;H
  /server\s*{/{
  :loop
  n;H
  /}/{
  b loop2
  }
  /{/!b loop
  :loop1
  n;H
  /}/!b loop1
  b loop
  }
  /}/{
  s/}/end-/;H
  s/end-//;x
  p
  }
  b loop2
  }
  " /tmp/nginx.conf`
  rm -f /tmp/nginx.conf
}

##########################################程序运行基本条件判断############################################################
command_check "egrep --help"
grep_reason=$reason
grep_check=$check_status

command_check "awk -W vesion"
if [ $check_status != "NOCHECK" ]; then
  awk_reason=$reason
  awk_check=$check_status
else
  command_check "awk --help"
  awk_reason=$reason
  awk_check=$check_status
fi

command_check "find --help"
find_reason=$reason
find_check=$check_status

command_check "wc --help"
wc_reason=$reason
wc_check=$check_status

command_check "ps"
ps_reason=$reason
ps_check=$check_status


if [ $grep_check = "NOCHECK" -o $awk_check = "NOCHECK" -o $find_check = "NOCHECK" -o $wc_check = "NOCHECK" -o $ps_check = "NOCHECK" ]; then
  exit 1
fi

####################################################获取配置文件的路径##################################################
mysql_installed=`LC_ALL=C ps -e | grep -i mysqld`
ora_installed=`LC_ALL=C ps -e |grep -i oracle`
apache_installed=`LC_ALL=C ps -e |grep -i httpd`
weblogic_installed=`LC_ALL=C ps -e | grep -i weblogic`
tomcat_installed=`LC_ALL=C ps -ef | grep -i tomcat | grep -v 'grep'`
nginx_installed=`LC_ALL=C ps -e |grep -i nginx`


if [ "$tomcat_installed" ]; then
 tomcat_installed_path=`LC_ALL=C ps -ef | grep tomcat | grep -Po 'Dcatalina.home=.*?\s' | awk -F '=' '{print $2}'`
 for j in ${tomcat_installed_path}; do
  tom_users_CONFIG=$tom_users_CONFIG"$j/conf/tomcat-users.xml "
  tom_server_CONFIG=$tom_server_CONFIG"$j/conf/server.xml "
  tom_web_CONFIG=$tom_web_CONFIG"$j/conf/web.xml "
 done
fi

if [ "$ora_installed" -a "$ORACLE_HOME" ]; then
  ORACLE_LISTENER_DIRECTORY=$ORACLE_HOME/network/admin/listener.ora
  ORACLE_SQLNET_DIRECTORY=$ORACLE_HOME/network/admin/sqlnet.ora
fi


if [ "$weblogic_installed" ]; then
  server_installed_path=`LC_ALL=C ps -ef | grep weblogic | grep -Po 'Dplatform.home=.*?\s' | awk -F '=' '{print $2}'` 
  for j in ${server_installed_path}; do
   weblogic_web_xml=$weblogic_web_xml"$j/server/lib/consoleapp/webapp/WEB-INF/web.xml "
   weblogic_xml=$weblogic_xml"$j/server/lib/consoleapp/webapp/WEB-INF/weblogic.xml "  
   weblogic_installed_path=`dirname $j`
   weblogic_registry_xml=$weblogic_registry_xml"$weblogic_installed_path/registry.xml "
   weblogic_config_tmp=`find / -name config.xml 2>/dev/null | grep -E -i "$weblogic_installed_path.*?/config/config.xml"`
   weblogic_config_xml=$weblogic_config_xml$weblogic_config_tmp" "
  done
fi

if [ "$nginx_installed" ]; then  
  nginx_CONFIG_DOCS=`LC_ALL=C ps -ef | grep nginx | grep -Po 'master\s*process.*' | awk '{print $5}'`
fi


##################################采集时间##################################################################################
TIMESTAMP=`LC_ALL=C date +%Y-%m-%d\ %H:%M:%S`
##################################主机配置##################################################################################
IP_ADDR=`LC_ALL=C ifconfig|grep "inet addr:"|grep -v "127.0.0.1"|cut -d: -f2|awk '{print $1}'`
MAC_ADDR=`LC_ALL=C ifconfig | grep -Po 'HWaddr.*' | awk '{print $2}'`
OS_FULLNAME=""
if [ -e "/etc/redhat-release" ]; then
 # CentOS
 FIND=`grep "CentOS" /etc/redhat-release`
 if [ ! "${FIND}" = "" ]; then
   OS_FULLNAME=$FIND
 fi
                
 # Red Hat
 FIND=`grep "Red Hat" /etc/redhat-release`
 if [ ! "${FIND}" = "" ]; then
   OS_FULLNAME=$FIND
 fi
fi

if [ -e "/etc/lsb-release" ]; then
  FIND=`grep "^DISTRIB_ID=" /etc/lsb-release | cut -d '=' -f2 | sed 's/"//g'`
  if [ "${FIND}" = "Ubuntu" ]; then
    OS_FULLNAME=`grep "^DISTRIB_DESCRIPTION=" /etc/lsb-release | cut -d '=' -f2 | sed 's/"//g'`
  fi
fi

if [ "${mysql_installed}" ]; then
 FIND=`mysql -V 2>/dev/null`
 if [ "${FIND}" ]; then
  version=`echo $FIND | awk '{print $5}'`
  version=`echo ${version%,}`
  db_type=$db_type"mysql/"$version" "
 else
  db_type=$db_type"mysql/- "
 fi
fi

if [ "${ora_installed}" ]; then
 if [ "${ORACLE_HOME}" ]; then
  version=`echo $ORACLE_HOME | grep -Po -i '/product/.*' | awk -F '/' '{print $3}'`
  db_type=$db_type"oracle/"$version" "
 else
  db_type=$db_type"oracle/- "
 fi
fi

if [ "${apache_installed}" ]; then
 FIND=`httpd -v 2>/dev/null`
 if [ "${FIND}" ]; then
  version=`echo $FIND | grep -i '^Server\s*version:' | awk -F ':' '{print $2}' | awk '{print $1}'`
  middleware_type=$middleware_type$version" "
 else
  middleware_type=$middleware_type"apache/- "
 fi  
fi

if [ "$nginx_installed" ]; then
  nginx_installed_path=`LC_ALL=C ps -ef | grep nginx | grep -Po 'master\s*process.*' | awk '{print $3}'`
  for j in ${nginx_installed_path}; do
    command=`$j -v 2>&1`
    if [ ! -z "${command}" ]; then
     version=`echo $command | grep -i 'nginx\s*version:' | awk -F ':' '{print $2}'`
     middleware_type=$middleware_type$version" "
    else
     middleware_type=$middleware_type"nginx/- "
    fi
  done
fi
  
if [ "${weblogic_installed}" ]; then
 for j in ${weblogic_registry_xml}; do
  if [ "${j}" -a -r $j ]; then
   version=`cat $j | grep -i 'component name="WebLogic Server"' | grep -Po -i 'version=".*?"' | awk -F '"' '{print $2}'`
   middleware_type=$middleware_type"weblogic/"$version" "
  else
   middleware_type=$middleware_type"weblogic/- "
  fi
 done
fi


if [ "${tomcat_installed}" ]; then
  parent_dir=`echo $tomcat_installed | grep -Po 'Dcatalina.home=.*?\s' | awk -F '=' '{print $2}'`
  for j in ${parent_dir}; do
   dir=$j"/bin/version.sh"
   command=`sh $dir 2>/dev/null`
   if [ ! -z "${command}" ]; then
    version=`echo $command | grep -Po -i 'Server\s*version:.*' | awk -F ':' '{print $2}' | awk '{print $2}'`
    middleware_type=$middleware_type$version" "
   else
    middleware_type=$middleware_type"tomcat/- "
   fi
  done
fi


###################################配置文件可查性检查#######################################################################
file_check 1 $passwd_DOCS, $passwd_DOCS linux-OS
LINUX_passwd_reason=$reason
LINUX_passwd_check=$check_status

file_check 1 $su_DOCS, $su_DOCS linux-OS
LINUX_su_reason=$reason
LINUX_su_check=$check_status

file_check 1 $logindefs_DOCS, $logindefs_DOCS linux-OS
LINUX_logindefs_reason=$reason
LINUX_logindefs_check=$check_status

file_check 1 $vsftp_DAEMON_CONFIG, vsftp.CONFIG linux-OS
LINUX_vsftpconfig_reason=$reason
LINUX_vsftpconfig_check=$check_status

file_check 1 $SYSLOG_CONFIG, SYSLOG.CONFIG linux-OS
LINUX_syslogconfig_reason=$reason
LINUX_syslogconfig_check=$check_status

file_check 1 $login_LOCS, $login_LOCS linux-OS
LINUX_login_reason=$reason
LINUX_login_check=$check_status

file_check 1 $SSH_DAEMON_CONFIG, $SSH_DAEMON_CONFIG linux-OS
LINUX_sshconfig_reason=$reason
LINUX_sshconfig_check=$check_status

file_check 1 $profile_LOCS, $profile_LOCS linux-OS
LINUX_profile_reason=$reason
LINUX_profile_check=$check_status

file_check 1 $group_DOCS, $group_DOCS linux-OS
LINUX_group_reason=$reason
LINUX_group_check=$check_status


if [ "$mysql_installed" ]; then
  mysql_installed_flag=1
else
  mysql_installed_flag=0
fi
file_check $mysql_installed_flag $MYSQL_CONFIG_DOCS, $MYSQL_CONFIG_DOCS mysqld
MYSQL_SQLNET_reason=$reason
MYSQL_SQLNET_check=$check_status


if [ "$ora_installed" ]; then
  ora_installed_flag=1
else
  ora_installed_flag=0
fi
file_check $ora_installed_flag $ORACLE_SQLNET_DIRECTORY, sqlnet.ora oracle
ORACLE_SQLNET_reason=$reason
ORACLE_SQLNET_check=$check_status

file_check $ora_installed_flag $ORACLE_LISTENER_DIRECTORY, listener.ora oracle
ORACLE_LISTENER_check=$check_status
ORACLE_LISTENER_reason=$reason


if [ "$apache_installed" ]; then
  apache_installed_flag=1
else
  apache_installed_flag=0
fi

file_check $apache_installed_flag $apache_CONFIG_DOCS, $apache_CONFIG_DOCS apache
apache_CONFIG_check=$check_status
apache_CONFIG_reason=$reason


if [ "$weblogic_installed" ]; then
  weblogic_installed_flag=1
else
  weblogic_installed_flag=0
fi

for j in ${weblogic_config_xml}; do
 file_check $weblogic_installed_flag $j, config.xml weblogic
 WEBLOGIC_CONFIG_reason=$WEBLOGIC_CONFIG_reason$reason" "
 if [ $check_status = "NOCHECK" ]; then
  WEBLOGIC_CONFIG_check="NOCHECK"
 fi
done




for j in ${weblogic_web_xml}; do
 file_check $weblogic_installed_flag $j, config.xml weblogic
 WEBLOGIC_WEB_reason=$WEBLOGIC_WEB_reason$reason" "
 if [ $check_status = "NOCHECK" ]; then
  WEBLOGIC_WEB_check="NOCHECK"
 fi
done

for j in ${weblogic_xml}; do
 file_check $weblogic_installed_flag $j, weblogic.xml weblogic
 WEBLOGIC_reason=$WEBLOGIC_reason$reason" "
 if [ $check_status = "NOCHECK" ]; then
  WEBLOGIC_check="NOCHECK"
 fi
done


if [ "$tomcat_installed" ]; then
  tomcat_installed_flag=1
else
  tomcat_installed_flag=0
fi

for j in ${tom_users_CONFIG}; do
 file_check $tomcat_installed_flag $j, tomcat-users.xml tomcat
 tom_users_reason=$tom_users_reason$reason" "
 if [ $check_status = "NOCHECK" ]; then
  tom_users_check="NOCHECK"
 fi
done

for j in ${tom_server_CONFIG}; do
 file_check $tomcat_installed_flag $j, server.xml tomcat
 tom_server_reason=$tom_server_reason$reason" "
 if [ $check_status = "NOCHECK" ]; then
  tom_server_check="NOCHECK"
 fi
done

for j in ${tom_web_CONFIG}; do
 file_check $tomcat_installed_flag $j, web.xml tomcat
 tom_web_reason=$tom_web_reason$reason" "
 if [ $check_status = "NOCHECK" ]; then
  tom_web_check="NOCHECK"
 fi
done

if [ "$nginx_installed" ]; then
  nginx_installed_flag=1
else
  nginx_installed_flag=0
fi

for j in ${nginx_CONFIG_DOCS}; do
 file_check $nginx_installed_flag $j, nginx.conf nginx
 nginx_config_reason=$nginx_config_reason$reason" "
 if [ $check_status = "NOCHECK" ]; then
  nginx_config_check="NOCHECK"
 fi
done

###################################命令可用性检查##########################################################################
command_check "passwd -S root"
passwd_S_reason=$reason
passwd_S_check=$check_status

command_check "ls -l"
ls_l_reason=$reason
ls_l_check=$check_status


command_check "chkconfig --list"
chkconfig_reason=$reason
chkconfig_check=$check_status



###########################linux操作系统####################################################################################
###########################4.3.1账号#####################################################
#######################01-是否有重复的操作系统账号#######################################
if [ $LINUX_passwd_check != "NOCHECK" ]; then  
 FIND=`cat ${passwd_DOCS} | awk -F ':' '{print $1}' | sort | uniq -c | sort -n | awk '{print $1"="$2;}'`
 for j in $FIND0;do
   username_repeat=`echo $j|awk -F= '{print $1}'`
   if [ $username_repeat -gt 1 ]; then
    os_username_unique="FALSE"
   fi
  done
else
 os_username_unique="NOCHECK"
 nocheck_reason_item57=$LINUX_passwd_reason
fi

#######################02-是否删除或锁定与设备运行、维护等工作无关的账号#################
nocheck_reason_item1=""

if [ $passwd_S_check = "NOCHECK" ]; then
 unrelated_user_lock="NOCHECK"
 nocheck_reason_item1=${nocheck_reason[2]}"passwd -S;"
fi

if [ $LINUX_passwd_check = "NOCHECK" ]; then
  unrelated_user_lock="NOCHECK"
  nocheck_reason_item1=$nocheck_reason_item1$LINUX_passwd_reason
fi

if [ $unrelated_user_lock != "NOCHECK" ]; then
 for I in ${required_locked_user}; do
  FIND=`cat ${passwd_DOCS} | grep "^${I}:"`
  if [ "${FIND}" ]; then
   FIND1=`LC_ALL=C passwd -S ${I} | awk '{print $2}'`
   if [ "${FIND1}" != "LK" ]; then
    unrelated_user_unlock="$unrelated_user_unlock""${I};"
    unrelated_user_lock="FALSE" 
   fi
  fi
 done
fi

#######################04-检查是否使用PAM认证模块禁止wheel组之外的用户su为root###########
if [ $LINUX_su_check != "NOCHECK" ]; then
 FIND=`cat ${su_DOCS} | grep -E -i '^(auth\s*sufficient\s*pam_rootok.so|auth\s*required\s*pam_wheel.so\s*group=wheel)' |wc -l`
 if [ $FIND -eq 2 ]; then
  pam_prohibit_nowheel_group_su_root="TRUE"
 fi
else
 pam_prohibit_nowheel_group_su_root="NOCHECK"
 nocheck_reason_item2=$passwd_S_reason
fi

#############################4.3.2授权######################################################
#######################01-检查/etc/passwd文件权限###########################################
nocheck_reason_item3=""

if [ $ls_l_check = "NOCHECK" ]; then
 etc_passwd_permission="NOCHECK"
 nocheck_reason_item3=${nocheck_reason[2]}"ls -l;"
fi

if [ ! -f "${passwd_DOCS}" ]; then
 etc_passwd_permission="NOCHECK"
 nocheck_reason_item3="$nocheck_reason_item3${nocheck_reason[1]}${passwd_DOCS}"
fi

if [ $etc_passwd_permission != "NOCHECK" ]; then
 FIND=`LC_ALL=C ls -l ${passwd_DOCS} | awk '{print $1}'`
 if [ "${FIND}" == "-rw-r--r--." -o "${FIND}" == "-rw-r--r--" -o "${FIND}" == "-r--r--r--." -o "${FIND}" == "-r--r--r--" ]; then
  etc_passwd_permission="TRUE"
 fi
 etc_passwd_permission_config=$FIND
fi

#######################01-检查/etc/shadow文件权限############################################
nocheck_reason_item4=""

if [ $ls_l_check = "NOCHECK" ]; then
 etc_shadow_permission="NOCHECK"
 nocheck_reason_item4=${nocheck_reason[2]}"ls -l;"
fi

if [ ! -f "${shadow_DOCS}" ]; then
 etc_shadow_permission="NOCHECK"
 nocheck_reason_item4="$nocheck_reason_item4${nocheck_reason[1]}${shadow_DOCS}"
fi

if [ $etc_shadow_permission != "NOCHECK" ]; then
 FIND=`LC_ALL=C ls -l ${shadow_DOCS} | awk '{print $1}'`
 if [ "${FIND}" == "-r--------." -o "${FIND}" == "-r--------" -o "${FIND}" == "----------." -o "${FIND}" == "----------" ]; then
  etc_shadow_permission="TRUE"
 fi
 etc_shadow_permission_config=$FIND
fi
#######################01-检查/etc/group文件权限############################################
nocheck_reason_item5=""

if [ $ls_l_check = "NOCHECK" ]; then
 etc_group_permission="NOCHECK"
 nocheck_reason_item5=${nocheck_reason[2]}"ls -l;"
fi

if [ ! -f "${group_DOCS}" ]; then
 etc_group_permission="NOCHECK"
 nocheck_reason_item5="$nocheck_reason_item5${nocheck_reason[1]}${group_DOCS}"
fi

if [ $etc_group_permission != "NOCHECK" ]; then
 FIND=`LC_ALL=C ls -l ${group_DOCS} | awk '{print $1}'`
 if [ "${FIND}" == "-rw-r--r--." -o "${FIND}" == "-rw-r--r--" -o "${FIND}" == "-r--r--r--." -o "${FIND}" == "-r--r--r--" ]; then
  etc_group_permission="TRUE"
 fi
 etc_group_permission_config=$FIND
fi

#######################02-检查用户目录缺省访问权限设置########################################
if [ $LINUX_logindefs_check != "NOCHECK" ]; then
 FIND=`cat ${logindefs_DOCS} | grep -i UMASK | grep -Ev '#' | awk '{print $2}'`
 if [ "${FIND}" ]; then
  umask_head=$((10#${FIND:0:1}))
  umask_middle=$((10#${FIND:1:1}))  
  umask_end=$((10#${FIND:2:1})) 
  if [ $umask_head -ge 0 -a $umask_middle -ge 2 -a $umask_end -ge 7 ]; then
   check_user_dir_default_accesss_permission="TRUE"
  fi 
  user_dir_default_accesss_permission_config=$FIND
 else
  user_dir_default_accesss_permission_config="未正确配置"
 fi
else
 check_user_dir_default_accesss_permission="NOCHECK"
 nocheck_reason_item6=$LINUX_logindefs_reason
fi

#######################03-检查是否限制FTP用户登录后能访问的目录##################################
if [ $LINUX_vsftpconfig_check != "NOCHECK" ]; then
 FIND=`cat ${vsftp_DAEMON_CONFIG} | grep -E -i '^(chroot_local_user=YES|#chroot_local_user=YES)' |wc -l`  
 if [ $FIND -ge 1 ]; then
  restrict_ftp_login_dir="TRUE"
 fi 
else
 restrict_ftp_login_dir="NOCHECK"
 nocheck_reason_item7=$LINUX_vsftpconfig_reason
fi
#############################4.3.3口令###########################################################
#######################01-检查口令最小长度#######################################################
logindefs_check="TRUE"
trap "nException=TRUE" ERR
cat ${logindefs_DOCS} >/dev/null 2>/dev/null
if [ $nException == "TRUE" ]; then
 logindefs_check="NOCHECK"
fi
nException=FALSE
trap " " ERR

PAM_check="FALSE"
trap "nException=TRUE" ERR
for I in ${PAM_LOCS}; do
 PAM="/etc/pam.d/${I}"
 cat ${PAM} >/dev/null 2>/dev/null
 if [ $nException == "FALSE" ]; then
  PAM_check="CHECK"
 fi
 nException=FALSE
done
trap " " ERR

if [ $logindefs_check == "NOCHECK" -a $PAM_check == "FALSE" ];then
 password_min_length="NOCHECK"
fi


if [ $logindefs_check != "NOCHECK" ];then
 FIND=`cat ${logindefs_DOCS} | grep -i '^PASS_MIN_LEN' | awk '{print $2}'`
 if [ "${FIND}" ]; then
  passwd_len1=$((10#${FIND}))
  if [ $passwd_len1 -ge 8 ]; then
   password_min_length="TRUE"
  fi
 fi
fi

if [ $PAM_check != "FALSE" ];then
for I in ${PAM_LOCS}; do
 if [ -f "/etc/pam.d/${I}" ]; then
  PAM="/etc/pam.d/${I}"
  FIND_PAM=`cat ${PAM} | grep -E -i '^(password\s*requisite\s*pam_cracklib.so)' | grep -Po -i 'minlen=\d*' | awk -F '=' '{print $2}'`
  if [ "${FIND_PAM}" ]; then
   passwd_len2=$((10#${FIND_PAM}))
   if [ $passwd_len2 -ge 8 ]; then
     password_min_length="TRUE"
   fi
  fi
 fi
done
fi

if [ "${FIND_PAM}" ]; then
 password_min_length_config=$passwd_len2
else
 if [ "${FIND}" ]; then
  password_min_length_config=$passwd_len1
 else
  password_min_length_config="未正确配置"
 fi
fi

#####################################01-检查口令组成###################################################
PAM_check="FALSE"
trap "nException=TRUE" ERR
for I in ${PAM_LOCS}; do
 PAM="/etc/pam.d/${I}"
 cat ${PAM} >/dev/null 2>/dev/null
 if [ $nException == "FALSE" ]; then
  PAM_check="CHECK"
 fi
nException=FALSE
done
trap " " ERR

if [ $PAM_check == "FALSE" ];then
 letter_classification="NOCHECK"
fi

if [ $PAM_check != "FALSE" ];then

for I in ${PAM_LOCS}; do
 if [ -f "/etc/pam.d/${I}" ]; then
  PAM="/etc/pam.d/${I}"
  FIND=`cat ${PAM} | grep -E -i '^(password\s*requisite\s*pam_cracklib.so)' | grep -Po -i 'minclass=\d*' | awk -F '=' '{print $2}'`
  if [ "${FIND}" ]; then
   letter_class_Num=$((10#${FIND}))
   if [ $letter_class_Num -ge 3 ]; then
     letter_classification="TRUE"
   fi
  fi
 fi
done


for I in ${PAM_LOCS}; do
 if [ -f "/etc/pam.d/${I}" ]; then
  PAM="/etc/pam.d/${I}"
  FIND1=`cat ${PAM} | grep -E -i '^(password\s*requisite\s*pam_cracklib.so)' | grep -Po -i '(dcredit=-[1-9][0-9]*|lcredit=-[1-9][0-9]*|ucredit=-[1-9][0-9]*|credit=-[1-9][0-9]*)' | wc -l`
  if [ $FIND1 -ge 3 ]; then
   letter_classification="TRUE"
   break
  fi
 fi
done

if [ -z "${FIND}" -a $FIND1 ]; then
 letter_classification_config=$FIND1
fi
if [ !$FIND1 -a "${FIND}" ]; then
 letter_classification_config=$letter_class_Num
fi
if [ !$FIND1 -a -z "${FIND}" ]; then
 letter_classification_config="未正确配置"
fi
if [ "${FIND}" -a $FIND1 ]; then
 if [ $FIND1 -eq $letter_class_Num ]; then
  letter_classification_config=$FIND1
 else
  letter_classification_config="未正确配置"
  letter_classification="FALSE"
 fi
fi

fi
#######################02-检查口令生存周期#######################################################
if [ $LINUX_logindefs_check != "NOCHECK" ]; then
 FIND=`cat ${logindefs_DOCS} |grep -E -i '^PASS_MAX_DAYS' | awk '{print $2}'`
 if [ "${FIND}" ]; then
  passwd_max_day=$((10#${FIND}))
  if [ $passwd_max_day -le 90 ]; then
   password_expire="TRUE"
  fi
 fi
 if [ "{FIND}" ]; then
  password_expire_config=$FIND
 else
  password_expire_config="未正确配置"
 fi
else
 password_expire="NOCHECK"
 nocheck_reason_item10=$LINUX_logindefs_reason
fi

#############################4.3.4日志############################################################
#######################01-检查syslog是否配置安全事件日志##########################################
if [ $LINUX_syslogconfig_check != "NOCHECK" ]; then
 FIND=`cat ${SYSLOG_CONFIG} | grep -E -i '^(authpriv.*\s*/var/log/secure|auth,authpriv.*\s*/var/log/auth.log)' | wc -l`
 if [ ${FIND} -eq 1 ]; then
  syslog_rsyslog_syslogn_secure="TRUE"
 fi
else
 syslog_rsyslog_syslogn_secure="NOCHECK"
 nocheck_reason_item11=$LINUX_syslogconfig_reason
fi

#######################02-检查系统日志文件是否other用户不可写######################################
if [ $ls_l_check = "NOCHECK" ]; then
 var_log_other_unwritable="NOCHECK"
 nocheck_reason_item12=${nocheck_reason[2]}"ls -l;"
fi

if [ $var_log_other_unwritable != "NOCHECK" ]; then  
for I in ${syslog_LOCS}; do
 if [ -f "${I}" ]; then
  FIND=`LC_ALL=C ls -l ${I} | awk '{print $1}'`
  if [ "${FIND:5:2}" != "--" -o "${FIND:8:2}" != "--" ]; then
   var_log_other_unwritable="FALSE"
   var_log_other_writable=$var_log_other_writable"${I};" 
   break
  fi
 fi
done
fi
   
#######################03-syslog是否启用记录cron行为日志功能#########################################
if [ $LINUX_syslogconfig_check != "NOCHECK" ]; then
 FIND=`cat ${SYSLOG_CONFIG} | grep -E -i '^(cron.*\s*/var/log/cron|cron.*\s*/var/log/cron.log)' | wc -l`
 if [ ${FIND} -eq 1 ]; then
  syslog_rsyslog_syslogn_cron="TRUE"
 fi
else
 syslog_rsyslog_syslogn_cron="NOCHECK"
 nocheck_reason_item13=$LINUX_syslogconfig_reason
fi

#######################04-syslog是否配置远程日志功能##################################################
if [ $LINUX_syslogconfig_check != "NOCHECK" ]; then
 FIND=`cat ${SYSLOG_CONFIG} |  grep -v '^#' | grep '@'`
 if [ "${FIND}" ]; then
  syslog_rsyslog_syslogn_remotetrans="TRUE"
 fi
else
 syslog_rsyslog_syslogn_remotetrans="NOCHECK"
 nocheck_reason_item14=$LINUX_syslogconfig_reason
fi

#############################4.3.5远程登录############################################################
#######################01-检查是否禁止root用户telnet远程登录##########################################
if [ $LINUX_login_check != "NOCHECK" ]; then
 FIND=`cat ${login_LOCS} |grep -E -i '^auth\s*required\s*pam_securetty.so'`
 if [ "${FIND}" ]; then
  root_login_telnet_forbidden="TRUE"
 fi
else
 root_login_telnet_forbidden="NOCHECK"
 nocheck_reason_item15=$LINUX_login_reason
fi

#######################01-检查是否禁止root用户ssh远程登录##############################################
if [ $LINUX_sshconfig_check != "NOCHECK" ]; then
 FIND=`cat ${SSH_DAEMON_CONFIG} |grep -E -i '^PermitRootLogin\s*no'`
 if [ "${FIND}" ]; then
  root_login_ssh_forbidden="TRUE"
 fi
else
 root_login_ssh_forbidden="NOCHECK"
 nocheck_reason_item16=$LINUX_sshconfig_reason
fi

##########02-检查使用IP协议进行远程维护的设备,是否配置使用SSH协议########################################
if [ ps_check != "NOCHECK" ]; then
 FIND=`LC_ALL=C ps -e | grep -i 'sshd'`
 if [ "${FIND}" ]; then
  ip_ssh_protocol="TRUE"
 fi
else
 ip_ssh_protocol="NOCHECK"
 nocheck_reason_item17=$ps_reason"ps"
fi

##########02-检查使用IP协议进行远程维护的设备,是否禁止使用telnet协议######################################
if [ $chkconfig_check != "NOCHECK" ]; then
 FIND=`LC_ALL=C chkconfig --list | grep -E -i 'on' | grep -i 'telnet:'`
 if [ "${FIND}" ]; then
  ip_telnet_protocol_forbidden="FALSE"
 fi
else
 ip_telnet_protocol_forbidden="NOCHECK"
 nocheck_reason_item18=$chkconfig_reason"chkconfig"
fi

##########02-检查使用IP协议进行远程维护的设备,是否安全配置SSHD############################################
if [ $LINUX_sshconfig_check != "NOCHECK" ]; then
 FIND=`cat ${SSH_DAEMON_CONFIG} | grep -E -i '^(Protocol\s*2|#Protocol\s*2|PermitRootLogin\s*no)' |wc -l`  
 if [ $FIND -eq 2 ]; then
  sshd_config_secure="TRUE"
 fi
else
 sshd_config_secure="NOCHECK"
 nocheck_reason_item19=$LINUX_sshconfig_reason
fi

#############################4.3.7不必要的服务##########################################################
#######################01-关闭不必要的服务##############################################################
if [ $chkconfig_check != "NOCHECK" ]; then
for I in ${require_stop_service}; do  
 FIND=`LC_ALL=C chkconfig --list | grep ${I}" " | grep -E -i 'on'`
 FIND1=`LC_ALL=C chkconfig --list | grep ${I}":" | grep -E -i 'on'`
 if [ "${FIND}" -o "${FIND1}" ]; then 
  unnessary_service_stop="FALSE"
  unnessary_service_nostop=$unnessary_service_nostop"${I};"
 fi
done
else
 unnessary_service_stop="NOCHECK"
 nocheck_reason_item20=$chkconfig_reason"chkconfig"
fi

#############################4.3.8系统Banner设置########################################################
###############01-检查系统banner,避免泄漏操作系统名称,版本号,主机名称等,并且给出登录告警信息############
for I in ${bannerconfig_LOCS}; do  
if [ -f "${I}" ]; then
 SYSTEM_BANNER="FALSE"
 break
fi
done

#############################4.3.9 FTP设置##############################################################
################################01-检查是否禁止root登录FTP##############################################
nocheck_reason_item22=""

if [ -z "${vsftp_DAEMON_CONFIG}" ]; then
  forbid_root_login_vsftp="NOCHECK"
  nocheck_reason_item22="$nocheck_reason_item22${nocheck_reason[3]}vsftp;"
else
 trap "nException=TRUE" ERR
 cat ${vsftp_DAEMON_CONFIG} >/dev/null 2>/dev/null
 if [ $nException == "TRUE" ]; then
  if [ ! -r "${vsftp_DAEMON_CONFIG}" ]; then
   forbid_root_login_vsftp="NOCHECK"
   nocheck_reason_item22="$nocheck_reason_item22${nocheck_reason[0]}${vsftp_DAEMON_CONFIG};"
  else
   forbid_root_login_vsftp="NOCHECK"
   nocheck_reason_item22="$nocheck_reason_item22${nocheck_reason[4]};"
  fi
 fi
 nException=FALSE
 trap " " ERR
fi

if [ -z "${BlackUser_list}" ]; then
  forbid_root_login_vsftp="NOCHECK"
  nocheck_reason_item22="$nocheck_reason_item22${nocheck_reason[1]}ftpusers;"
else 
 trap "nException=TRUE" ERR
 cat ${BlackUser_list} >/dev/null 2>/dev/null
 if [ $nException == "TRUE" ]; then 
  if [ ! -r "${BlackUser_list}" ]; then
   forbid_root_login_vsftp="NOCHECK"
   nocheck_reason_item22="$nocheck_reason_item22${nocheck_reason[0]}${BlackUser_list};"
  else
   forbid_root_login_vsftp="NOCHECK"
   nocheck_reason_item22="$nocheck_reason_item22${nocheck_reason[4]};"
  fi
 fi
 nException=FALSE
 trap " " ERR
fi
  
if [ $forbid_root_login_vsftp != "NOCHECK" ]; then 
FIND=`cat ${vsftp_DAEMON_CONFIG} | grep -v "^#" | sed 's/=/ /g' | grep -i "^pam_service_name" | awk '{ print $2 }'`
pam_service_name=$FIND
vsftp_PAM="/etc/pam.d/${pam_service_name}"
fi

if [ -z "${vsftp_PAM}" ]; then
  forbid_root_login_vsftp="NOCHECK"
  nocheck_reason_item22="$nocheck_reason_item22${nocheck_reason[1]}/etc/pam.d/vsftpd;"
else
 trap "nException=TRUE" ERR
 cat ${vsftp_PAM} >/dev/null 2>/dev/null
 if [ $nException == "TRUE" ]; then
  if [ ! -r "${vsftp_PAM}" ]; then
   forbid_root_login_vsftp="NOCHECK"
   nocheck_reason_item22="$nocheck_reason_item22${nocheck_reason[0]}${vsftp_PAM};"
  else
   forbid_root_login_vsftp="NOCHECK"
   nocheck_reason_item22="$nocheck_reason_item22${nocheck_reason[4]};"
  fi
 fi
 nException=FALSE
 trap " " ERR  
fi
 
if [ $forbid_root_login_vsftp != "NOCHECK" ]; then 
 FIND1=`cat ${BlackUser_list} | grep -v "^#" | grep -i "root"`
 FIND2=`cat ${vsftp_PAM} | grep -v "^#" |grep -i "^auth" | grep -i "pam_listfile.so"`
 if [ "${FIND2}" -a "${FIND1}" ]; then
 forbid_root_login_vsftp="TRUE"
 fi
fi

################################02-检查是否禁止匿名登录FTP##############################################
if [ $LINUX_vsftpconfig_check != "NOCHECK" ]; then 
 FIND=`cat ${vsftp_DAEMON_CONFIG} | grep -E -i "^anonymous_enable=NO"`
 if [ "${FIND}" ]; then
  forbid_anonymous_vsftpd_login="TRUE"
 fi
else
 forbid_anonymous_vsftpd_login="NOCHECK"
 nocheck_reason_item23=$LINUX_vsftpconfig_reason
fi

#############################4.3.10 登录超时时间设置####################################################
################################01-检查系统是否配置定时账号自动登出#####################################
if [ $LINUX_profile_check != "NOCHECK" ]; then 
 FIND=`cat ${profile_LOCS} | grep -v '^#' | grep -i 'TMOUT='`
 if [ "${FIND}" ]; then
  set_terminal_timeout="TRUE"
  terminal_time_config=$FIND
 else
 terminal_time_config="未正确配置"
 fi
else
 set_terminal_timeout="NOCHECK"
 nocheck_reason_item24=$LINUX_profile_reason
fi

#############################4.3.11 删除潜在危险文件####################################################
################################01-检查系统是否含有.rhosts\.netrc\hosts.equiv等危险文件#################
for I in ${danger_file}; do  
 FIND=`LC_ALL=C find / -name ${I} 2>/dev/null`
 if [ "${FIND}" ]; then
  danger_file_not_exist="FALSE"
  danger_file_list=$danger_file_list"${I};"
 fi 
done

###########################MYSQL数据库####################################################################################
###########################4.3.1 账号################################################################################
###########################01-检查是否以普通账户mysql安全运行数据库##################################################
nocheck_reason_item26=""

if [ ps_check != "NOCHECK" ]; then
FIND=`LC_ALL=C ps -e | grep -i mysqld`
if [ "${FIND}" ]; then
 FIND=`LC_ALL=C ps -ef | grep -i mysqld | grep -i 'user=mysql'`
 if [ "${FIND}" ]; then
  noroot_run_mysqld="TRUE"
 fi
else
 noroot_run_mysqld="NOCHECK"
 nocheck_reason_item26="$nocheck_reason_item26${nocheck_reason[3]}mysqld;"
fi
else
 noroot_run_mysqld="NOCHECK"
 nocheck_reason_item26=$ps_reason"ps"
fi

#####################################4.3.4 日志########################################################################
#####################################01-检查数据库是否配置日志功能#####################################################
if [ $MYSQL_SQLNET_check != "NOCHECK" ]; then 
 FIND=`cat ${MYSQL_CONFIG_DOCS} | grep -E -i '^(log-err=|log-update=|log-bin=)' |wc -l`  
 if [ $FIND -eq 3 ]; then
  config_log_files_mysqld="TRUE"
 fi 
else
 config_log_files_mysqld="NOCHECK"
 nocheck_reason_item27=$MYSQL_SQLNET_reason
fi

###########################Oracle数据库####################################################################################
############################4.4.1 账号#########################################################
############################05-检查DBA组中是否只有oracle安装用户#########################
nocheck_reason_item28=""

if [ $LINUX_group_check = "NOCHECK" ]; then
  only_oracle_belong_dba="NOCHECK"
  nocheck_reason_item28=$nocheck_reason_item28$LINUX_group_reason";"
fi

if [ $LINUX_passwd_check = "NOCHECK" ]; then
  only_oracle_belong_dba="NOCHECK"
  nocheck_reason_item28=$nocheck_reason_item28$LINUX_passwd_reason
fi

if [ $only_oracle_belong_dba != "NOCHECK" ]; then 
dba_id=`cat ${group_DOCS} | grep -i ^dba | awk -F: '{print $3}'`
dba_usernum=`cat ${passwd_DOCS} | awk -F: '{print $4}' | grep -i "$dba_id" | wc -l`
if [ $dba_usernum -eq 1 ]; then
   only_oracle_belong_dba="TRUE"
fi
fi

############################4.4.6 Listener安全###########################################
############################01-检查是否为Listener的关闭和启动设置密码#########################
if [ $ORACLE_LISTENER_check != "NOCHECK" ]; then 
 FIND=`cat ${ORACLE_LISTENER_DIRECTORY} | grep -i '^PASSWORDS_LISTENER\s*='`
 if [ "${FIND}" ]; then
  set_passwd_for_listener_ora="TRUE"
 fi
else
 set_passwd_for_listener_ora="NOCHECK"
 nocheck_reason_item29=$ORACLE_LISTENER_reason
fi

############################4.4.7 连接超时设置###########################################
############################01-检查是否设置连接超时自动断开##############################
if [ $ORACLE_SQLNET_check != "NOCHECK" ]; then 
 FIND=`cat ${ORACLE_SQLNET_DIRECTORY} | grep -i '^(sqlnet.expire_time\s*=)'`
 if [ "${FIND}" ]; then
  config_expire_time_ora="TRUE"
  expire_time=`$FIND | awk -F '=' '{print $2}'`
 fi
else
 config_expire_time_ora="NOCHECK"
 nocheck_reason_item30=$ORACLE_SQLNET_reason
fi

############################4.4.8 可信IP地址访问控制###########################################
############################01-检查是否设置基于IP地址的访问控制################################
if [ $ORACLE_SQLNET_check != "NOCHECK" ]; then 
 FIND=`cat ${ORACLE_SQLNET_DIRECTORY} | grep -i '^tcp.validnode_checking\s*=\s*yes'`
 if [ $FIDN ]; then
  config_whitelist_based_IP_ora="TRUE"
  invited_nodes=`cat ${ORACLE_SQLNET_DIRECTORY} | grep -i '^tcp.invited_nodes' | awk -F '=' '{print $2}'`
 fi
else
 config_whitelist_based_IP_ora="NOCHECK"
 nocheck_reason_item31=$ORACLE_SQLNET_reason
fi

############################4.4.9 数据传输安全#################################################
############################01-检查是否加密网络传输数据（可选）################################
if [ $ORACLE_SQLNET_check != "NOCHECK" ]; then 
 FIND=`cat ${ORACLE_SQLNET_DIRECTORY} | grep -E -i '^sqlnet.encryption'`
 if [ "${FIND}" ]; then
  config_encryption_ora="TRUE"
 fi
else
 config_encryption_ora="NOCHECK"
 nocheck_reason_item32=$ORACLE_SQLNET_reason
fi

##################################nginx#################################################################################
############################4.2.1 账号#################################################
############################01-检查是否以普通用户和组运行nginx################################
if [ $nginx_config_check != "NOCHECK" ]; then 
for j in ${nginx_CONFIG_DOCS}; do 
 FIND=`cat $j | grep -i '^user.*'| awk '{print $2}'`
 FIND1=`cat $j | grep -i '^user.*'| awk '{print $3}'`
 if [ "$FIND" = "root" -o "$FIND1" = "root;" ]; then
  noroot_run_nginx="FALSE"
 fi
done
else
 noroot_run_nginx="NOCHECK"
 nocheck_reason_item58=$nginx_config_reason
fi

############################4.2.2 授权#################################################
############################01-检查是否禁止nginx访问Web目录之外的任何文件################################
if [ $nginx_config_check != "NOCHECK" ]; then 
for j in ${nginx_CONFIG_DOCS}; do 
all_nginx_server_module $j
FIND=`echo $nginx_server_info | tr [" "] ["_"]| grep -Po 'server.*?end-'`
for I in $FIND; do
 FIND1=`echo $I | grep -Po 'rewrite.*?permanent'`
 if [ -z "${FIND1}" ]; then
   FIND2=`echo $I | grep -Po 'location\s*/\s*{.*?deny\s*all;.*?}'`
   if [ -z "${FIND2}" ]; then
     only_vist_specific_dir_ngn="FALSE"
   fi
 fi
done
done
else
 only_vist_specific_dir_ngn="NOCHECK"
 nocheck_reason_item59=$nginx_config_reason
fi

############################4.2.3 日志#################################################
############################01-检查是否配置用户登录日志################################
if [ $nginx_config_check != "NOCHECK" ]; then 
for j in ${nginx_CONFIG_DOCS}; do 
nginx_http_no_server $j
FIND0=`echo $nginx_http_no_server | grep -Po 'access_log.*?end-'`
if [ -z "${FIND0}" ]; then
 nginx_server_no_location $j
 FIND=`echo $nginx_server_no_location | tr [" "] ["_"]| grep -Po 'server.*?end-'`
 for I in $FIND; do
  FIND1=`echo $I | grep -Po 'rewrite.*?permanent'`
  if [ -z "${FIND1}" ]; then
   FIND2=`echo $I | grep -Po 'access_log'`
   if [ -z "${FIND2}" ]; then
    error_access_log_ngn="FALSE"
   fi
  fi
 done
fi
done
else
 error_access_log_ngn="NOCHECK"
 nocheck_reason_item60=$nginx_config_reason
fi

############################4.2.4 其他#################################################
############################01-检查是否配置nginx错误页面重定向################################
if [ $nginx_config_check != "NOCHECK" ]; then 
for j in ${nginx_CONFIG_DOCS}; do 
nginx_http_no_server $j
FIND0=`echo $nginx_http_no_server | grep -Po 'error_page.*?end-'`
if [ -z "${FIND0}" ]; then
 nginx_server_no_location $j
 FIND=`echo $nginx_server_no_location | tr [" "] ["_"]| grep -Po 'server.*?end-'`
 for I in $FIND; do
  FIND1=`echo $I | grep -Po 'rewrite.*?permanent'`
  if [ -z "${FIND1}" ]; then
   FIND2=`echo $I | grep -Po 'error_page'`
   if [ -z "${FIND2}" ]; then
    error_page_redir_ngn="FALSE"
   fi
  fi
 done
fi
done
else
 error_page_redir_ngn="NOCHECK"
 nocheck_reason_item61=$nginx_config_reason
fi

############################02-检查是否禁止nginx列表显示文件################################
if [ $nginx_config_check != "NOCHECK" ]; then 
for j in ${nginx_CONFIG_DOCS}; do 
nginx_http_no_server $j
FIND0=`echo $nginx_http_no_server | grep -Po 'autoindex\s*on.*?end-'`
if [ "${FIND0}" ]; then
 forbid_file_list_when_indexhtml_not_exitst_ngn="FALSE"
else
 nginx_server_no_location $j
 FIND=`echo $nginx_server_no_location | tr [" "] ["_"]| grep -Po 'server.*?end-'`
 for I in $FIND; do
  FIND1=`echo $I | grep -Po 'rewrite.*?permanent'`
  if [ -z "${FIND1}" ]; then
   FIND2=`echo $I | grep -Po 'autoindex\s*on'`
   if [ "${FIND2}" ]; then
    forbid_file_list_when_indexhtml_not_exitst_ngn="FALSE"
   fi
  fi
 done
fi
done
else
 forbid_file_list_when_indexhtml_not_exitst_ngn="NOCHECK"
 nocheck_reason_item62=$nginx_config_reason
fi

############################03-检查是否配置拒绝服务防范################################
if [ $nginx_config_check != "NOCHECK" ]; then 
for j in ${nginx_CONFIG_DOCS}; do 
 FIND=`cat $j | grep -E -i '^\s*(worker_processes|worker_connections)' | wc -l`
 if [ $FIND -ne 2 ]; then
  anti_DOS_attack_ngn="FALSE"
 fi
done
else
 anti_DOS_attack_ngn="NOCHECK"
 nocheck_reason_item63=$nginx_config_reason
fi

############################05-检查是否隐藏nginx的版本号及其他敏感信息################################
if [ $nginx_config_check != "NOCHECK" ]; then 
for j in ${nginx_CONFIG_DOCS}; do 
nginx_http_no_server $j
FIND0=`echo $nginx_http_no_server | grep -Po 'server_tokens\s*off.*?end-'`
if [ -z "${FIND0}" ]; then
 nginx_server_no_location $j
 FIND=`echo $nginx_server_no_location | tr [" "] ["_"]| grep -Po 'server.*?end-'`
 for I in $FIND; do
  FIND1=`echo $I | grep -Po 'rewrite.*?permanent'`
  if [ -z "${FIND1}" ]; then
   FIND2=`echo $I | grep -Po 'server_tokens\s*off'`
   if [ -z "${FIND2}" ]; then
    sensitive_information_hidden_ngn="FALSE"
   fi
  fi
 done
fi
done
else
 sensitive_information_hidden_ngn="NOCHECK"
 nocheck_reason_item64=$nginx_config_reason
fi

############################Apache###################################################################################
############################4.2.1 账号#################################################
############################01-检查是否以普通用户和组运行apache################################
if [ $apache_CONFIG_check != "NOCHECK" ]; then 
 FIND=`cat ${apache_CONFIG_DOCS} | grep -i '^User.*'| awk '{print $2}'`
 FIND1=`cat ${apache_CONFIG_DOCS} | grep -i '^Group.*'| awk '{print $2}'`
 if [ "$FIND" != "root" -a "$FIND1" != "root" ]; then
  noroot_run_apache="TRUE"
 fi
else
 noroot_run_apache="NOCHECK"
 nocheck_reason_item33=$apache_CONFIG_reason
fi

############################4.2.2 授权#################################################
############################01-检查是否禁止Apache访问Web目录之外的任何文件################################
if [ $apache_CONFIG_check != "NOCHECK" ]; then 
 FIND=`sed -e ':a' -e '$!N;s/\n/?/;ta' ${apache_CONFIG_DOCS} | sed 's/#\s*/#/g' | grep -Po -i '[^#]<Directory\s*/>.*?[^#]Order\s*Deny\s*,\s*Allow.*?[^#]Deny\s*from\s*all.*?[^#]</Directory>'`  
 if [ "${FIND}" ]; then
  only_vist_specific_dir_apa="TRUE"
 fi
else
 only_vist_specific_dir_apa="NOCHECK"
 nocheck_reason_item34=$apache_CONFIG_reason
fi


############################4.2.3 日志#################################################
############################01-检查是否配置用户登录日志################################
if [ $apache_CONFIG_check != "NOCHECK" ]; then 
 FIND=`cat ${apache_CONFIG_DOCS} | grep -E -i '^CustomLog\s*logs/' | awk '{print $3}'`
 if [ "${FIND}" ]; then
  FIND1=`cat ${apache_CONFIG_DOCS} | grep -E -i '^(LogFormat\s*"%h\s*%l\s*%u\s*%t.*?"%r.*?"\s*%>s\s*%b)' | grep "$FIND"`
  if [ "${FIND1}" ]; then
    error_access_log_apa="TRUE"
  fi
 fi
else
 error_access_log_apa="NOCHECK"
 nocheck_reason_item35=$apache_CONFIG_reason   
fi

############################4.2.4 其他#################################################
############################01-检查是否配置apache错误页面重定向################################
if [ $apache_CONFIG_check != "NOCHECK" ]; then 
 FIND=`cat ${apache_CONFIG_DOCS} | grep -v "^#" | grep -i 'ErrorDocument\s*[4-5][0-9]\{1,2\}\s*/.*?.html'`
 if [ "${FIND}" ]; then
  error_page_redir_apa="TRUE"
 fi
else
 error_page_redir_apa="NOCHECK"
 nocheck_reason_item36=$apache_CONFIG_reason  
fi

############################02-检查是否禁止Apache列表显示文件################################
if [ $apache_CONFIG_check != "NOCHECK" ]; then 
 FIND=`cat ${apache_CONFIG_DOCS} | tr ["\n"] ["?"] | sed 's/#\s*/#/g' | grep -Po -i '[^#]<Directory\s*".*?">.*?[^#]Options\s*Indexes\s*?FollowSymLinks.*?[^#]</Directory>'`
 if [ "${FIND}" ]; then
  forbid_file_list_when_indexhtml_not_exitst_apa="FALSE"
 fi
else
 forbid_file_list_when_indexhtml_not_exitst_apa="NOCHECK"
 nocheck_reason_item37=$apache_CONFIG_reason  
fi

############################03-检查是否配置拒绝服务防范################################
if [ $apache_CONFIG_check != "NOCHECK" ]; then 
 FIND=`cat ${apache_CONFIG_DOCS} | grep -E -i '^(Timeout|KeepAlive\s*On|KeepAliveTimeout|AcceptFilter\s*http\s*data|AcceptFilter\s*https\s*data)' |wc -l`  
 if [ $FIND -eq 5 ]; then
  anti_DOS_attack_apa="TRUE"
 fi
else
 anti_DOS_attack_apa="NOCHECK"
 nocheck_reason_item38=$apache_CONFIG_reason  
fi

############################05-检查是否隐藏Apache的版本号及其他敏感信息################################
if [ $apache_CONFIG_check != "NOCHECK" ]; then 
 FIND=`cat ${apache_CONFIG_DOCS} | grep -E -i '^(ServerSignature\s*Off|ServerTokens\s*Prod)' |wc -l`  
 if [ $FIND -eq 2 ]; then
  sensitive_information_hidden_apa="TRUE"
 fi
else
 sensitive_information_hidden_apa="NOCHECK"
 nocheck_reason_item39=$apache_CONFIG_reason 
fi

#############################Weblogic##################################################################################
############################4.7.1 账号############################################################
############################01-检查weblogic管理员是否为root和nobody###############################
if [ $WEBLOGIC_CONFIG_check != "NOCHECK" ]; then 
 for j in ${weblogic_config_xml}; do
  FIND=`cat $j | tr ["\n"] [" "] | grep -Po '<node-manager-username>.*?</node-manager-username>' | awk -F '<' '{print $2}' | awk -F '>' '{print $2}'`
  for I in ${FIND}; do
   if [ "${FIND}" = "root" -o "${FIND}" = "nobody" ]; then
    weblogic_admin_not_root="FALSE"
   fi
  done
 done
else
  weblogic_admin_not_root="NOCHECK"
  nocheck_reason_item40=$WEBLOGIC_CONFIG_reason 
fi

############################4.7.2 口令############################################################
############################01-检查weblogic口令长度###############################################
if [ $WEBLOGIC_CONFIG_check != "NOCHECK" ]; then 
 for j in ${weblogic_config_xml}; do
  FIND=`cat $j | tr ["\n"] [" "] | grep -Po '<sec:password-validator.*?<sec:name>SystemPasswordValidator</sec:name>.*?</sec:password-validator>'`
  FIND1=`echo ${FIND} | grep -Po '<pas:min-password-length>[0-9]*?</pas:min-password-length>' | awk -F '<' '{print $2}' | awk -F '>' '{print $2}'`
  if [ "${FIND1}" ]; then
   min_password_length=$((10#${FIND1}))
   if [ $min_password_length -lt 8 ]; then
     weblogic_password_long_enough="FALSE" 
   fi
  fi
 done
else
 weblogic_password_long_enough="NOCHECK"
 nocheck_reason_item41=$WEBLOGIC_CONFIG_reason 
fi

###################################01-weblogic口令类型###########################################
if [ $WEBLOGIC_CONFIG_check != "NOCHECK" ]; then 
for j in ${weblogic_config_xml}; do
 FIND=`cat $j | tr ["\n"] [" "] | grep -Po '<sec:password-validator.*?<sec:name>SystemPasswordValidator</sec:name>.*?</sec:password-validator>'`
 min_alphabetic_characters=`echo ${FIND} | grep -Po ' <pas:min-alphabetic-characters>[0-9]*?</pas:min-alphabetic-characters>' | awk -F '<' '{print $2}' | awk -F '>' '{print $2}'`
 min_numeric_characters=`echo ${FIND} | grep -Po '<pas:min-numeric-characters>[0-9]*?</pas:min-numeric-characters>' | awk -F '<' '{print $2}' | awk -F '>' '{print $2}'`
 min_lowercase_characters=`echo ${FIND} | grep -Po '<pas:min-lowercase-characters>[0-9]*?</pas:min-lowercase-characters>' | awk -F '<' '{print $2}' | awk -F '>' '{print $2}'`
 min_uppercase_characters=`echo ${FIND} | grep -Po '<pas:min-uppercase-characters>[0-9]*?</pas:min-uppercase-characters>' | awk -F '<' '{print $2}' | awk -F '>' '{print $2}'`
 min_non_alphanumeric_characters=`echo ${FIND} | grep -Po '<pas:min-non-alphanumeric-characters>[0-9]*?</pas:min-non-alphanumeric-characters>' | awk -F '<' '{print $2}' | awk -F '>' '{print $2}'`
 min_numeric_or_special_characters=`echo ${FIND} | grep -Po '<pas:min-numeric-or-special-characters>[0-9]*?</pas:min-numeric-or-special-characters>' | awk -F '<' '{print $2}' | awk -F '>' '{print $2}'`

 if [ "${min_alphabetic_characters}" ]; then
  weblogic_min_alphabetic_characters=$((10#${min_alphabetic_characters}))
 else
  weblogic_min_alphabetic_characters=0
 fi

 if [ "${min_numeric_characters}" ]; then
  weblogic_min_numeric_characters=$((10#${min_numeric_characters}))
 else
  weblogic_min_numeric_characters=0
 fi

 if [ "${min_lowercase_characters}" ]; then
  weblogic_min_lowercase_characters=$((10#${min_lowercase_characters}))
 else
  weblogic_min_lowercase_characters=0
 fi

 if [ "${min_uppercase_characters}" ]; then
  weblogic_min_uppercase_characters=$((10#${min_uppercase_characters}))
 else
  weblogic_min_uppercase_characters=0
 fi

 if [ "${min_non_alphanumeric_characters}" ]; then
  weblogic_min_non_alphanumeric_characters=$((10#${min_non_alphanumeric_characters}))
 else
  weblogic_min_non_alphanumeric_characters=0
 fi


 if [ "${min_numeric_or_special_characters}" ]; then
  weblogic_min_numeric_or_special_characters=$((10#${min_numeric_or_special_characters}))
 else
  weblogic_min_numeric_or_special_characters=0
 fi

 if [ $weblogic_min_numeric_characters -gt 0 -a $weblogic_min_lowercase_characters -gt 0 -a $weblogic_min_uppercase_characters -gt 0 ]; then
  letter_classification="TRUE"
 elif [ $weblogic_min_numeric_or_special_characters -gt 0 -a $weblogic_min_lowercase_characters -gt 0 -a $weblogic_min_uppercase_characters -gt 0 ]; then 
  letter_classification="TRUE"
 elif [ $weblogic_min_numeric_characters -gt 0 -a $weblogic_min_alphabetic_characters -gt 0 -a $weblogic_min_non_alphanumeric_characters -gt 0 ]; then 
  letter_classification="TRUE"
 elif [ $weblogic_min_numeric_characters -gt 0 -a $weblogic_min_lowercase_characters -gt 0 -a $weblogic_min_non_alphanumeric_characters -gt 0 ]; then 
  letter_classification="TRUE"
 elif [ $weblogic_min_numeric_characters -gt 0 -a $weblogic_min_uppercase_characters -gt 0 -a $weblogic_min_non_alphanumeric_characters -gt 0 ]; then 
  letter_classification="TRUE"
 elif [ $weblogic_min_lowercase_characters -gt 0 -a $weblogic_min_uppercase_characters -gt 0 -a $weblogic_min_non_alphanumeric_characters -gt 0 ]; then 
  letter_classification="TRUE" 
 else
  letter_classification="FALSE"
 fi
 
 if [ $letter_classification = "FALSE" ]; then
  weblogic_letter_classification="FALSE"
 fi
 
done
else
 weblogic_letter_classification="NOCHECK"
 nocheck_reason_item42=$WEBLOGIC_CONFIG_reason 
fi

############################4.7.4 日志############################################################
########################################01-检查是否配置用户登录日志###############################
if [ $WEBLOGIC_CONFIG_check != "NOCHECK" ]; then 
for j in ${weblogic_config_xml}; do 
 FIND=`cat $j | tr ["\n"] [" "] | grep -Po '<web-server-log>.*?</web-server-log>'`
 FIND1=`echo ${FIND} | grep -Po '<log-file-format>.*?</log-file-format>' | awk -F '<' '{print $2}' | awk -F '>' '{print $2}'`
 if [ -z "${FIND1}" ]; then
  FIND1="common"
 fi

 if [ "${FIND1}" != "common" ]; then
  FIND2=`echo ${FIND} | grep -Po '<elf-fields>.*?</elf-fields>' | awk -F '<' '{print $2}' | awk -F '>' '{print $2}'`
  if [ -z "${FIND2}" ]; then
   FIND2="date time cs-method cs-uri sc-status"
  fi
  FIND0=`echo ${FIND2} | grep date | grep time | grep cs-method | grep sc-status | grep c-ip`
 fi
 if [ -z "${FIND0}" -a $FIND1 != "common" ]; then
   weblogic_log_config="FALSE"
 fi
done
else
 weblogic_log_config="NOCHECK"
 nocheck_reason_item43=$WEBLOGIC_CONFIG_reason 
fi

############################4.7.5 IP协议###########################################################
########################################01-检查Sockets最大打开数目(可选)###########################
if [ $WEBLOGIC_CONFIG_check != "NOCHECK" ]; then 
for j in ${weblogic_config_xml}; do 
 FIND=`cat $j | tr ["\n"] [" "] | grep -Po '<max-open-sock-count>.*?</max-open-sock-count>' | awk -F '<' '{print $2}' | awk -F '>' '{print $2}'`
 if [ -z "${FIND}" ]; then
  FIND="-1"
 fi
 max_open_sock_count=$((10#${FIND}))

 if [ $max_open_sock_count -gt 1024 -o $max_open_sock_count -lt 0 ]; then
     weblogic_max_open_socket_count="FALSE" 
 fi
done
else
 weblogic_max_open_socket_count="NOCHECK"
 nocheck_reason_item44=$WEBLOGIC_CONFIG_reason
fi

########################################02-检查weblogic是否禁用Send-Server-Header(可选)#############
if [ $WEBLOGIC_CONFIG_check != "NOCHECK" ]; then 
for j in ${weblogic_config_xml}; do 
 FIND=`cat $j | tr ["\n"] [" "] | grep -Po '<send-server-header-enabled>.*?</send-server-header-enabled>'`
 FIND1=`echo ${FIND} | awk -F '<' '{print $2}' | awk -F '>' '{print $2}'`
 if [ -z "${FIND1}" ]; then
  FIND1="false"
 fi
 if [ "$FIND1" != "false" ]; then
    weblogic_send_server_header_forbidden="FALSE" 
 fi
done
else
 weblogic_send_server_header_forbidden="NOCHECK"
 nocheck_reason_item45=$WEBLOGIC_CONFIG_reason
fi

############################4.7.5 其他###############################################################
########################################01-检查weblogic是否配置定时账号自动登出######################
if [ $WEBLOGIC_CONFIG_check != "NOCHECK" ]; then 
for j in ${weblogic_config_xml}; do 
 FIND=`cat $j | tr ["\n"] [" "] | grep -Po '<login-timeout-millis>.*?</login-timeout-millis>'`
 for I in ${FIND}; do 
 FIND1=`echo $I | awk -F '<' '{print $2}' | awk -F '>' '{print $2}'`
 if [ "${FIND1}" ]; then
  login_timeout_millis=$((10#${FIND1}))
  if [ $login_timeout_millis -eq 0 ]; then
     weblogic_login_timeout_millis="FALSE" 
  fi
 else
  weblogic_login_timeout_millis="FALSE" 
 fi
done
done
else
 weblogic_login_timeout_millis="NOCHECK"
 nocheck_reason_item46=$WEBLOGIC_CONFIG_reason
fi

########################################02-检查是否配置weblogic错误页面重定向#########################
if [ $WEBLOGIC_WEB_check != "NOCHECK" ]; then 
for j in ${weblogic_web_xml}; do 
 FIND=`cat $j | tr ["\n"] [" "] | grep -Po '<error-page>.*?</error-page>'`
 if [ -z "${FIND}" ]; then
  weblogic_error_page="FALSE"
 fi
done
else
 weblogic_error_page="NOCHECK"
 nocheck_reason_item47=$WEBLOGIC_WEB_reason
fi

########################################03-检查是否禁止weblogic列表显示文件############################
if [ $WEBLOGIC_CONFIG_check != "NOCHECK" ]; then 
for j in ${weblogic_config_xml}; do
 FIND=`cat $j | tr ["\n"] [" "] | grep -Po '<index-directory-enabled>true</index-directory-enabled>'`
 if [ "${FIND}" ]; then
  FIND="false"
 fi
done
else
 FIND="nocheck"
fi

if [ $WEBLOGIC_check != "NOCHECK" ]; then 
for j in ${weblogic_xml}; do
 FIND1=`cat $j | tr ["\n"] [" "] | grep -Po '<index-directory-enabled>true</index-directory-enabled>'`
 if [ "${FIND1}" ]; then
  FIND1="false"
 fi
done
else
 FIND1="nocheck"
fi

if [ "$FIND" = "false" -o "$FIND1" = "false" ]; then
  weblogic_index_directory_forbidden="FALSE"
elif [ "$FIND" = "nocheck" -a "$FIND1" = "nocheck" ]; then
  weblogic_index_directory_forbidden="NOCHECK"
  nocheck_reason_item48=$WEBLOGIC_reason$WEBLOGIC_CONFIG_reason
fi

##################################Tomcat#################################################################################
##################################4.3.1 账号###############################################################
##################################01-检查Tomcat账号是否为空###################################################
if [ $tom_users_check != "NOCHECK" ]; then
for j in ${tom_users_CONFIG}; do 
 tom_users_CONFIG_DOCS=`cat $j | sed '/<!--/{:a;/-->/!{N;ba}};/<!--/d'`
 FIND=`echo ${tom_users_CONFIG_DOCS} | tr ["\n"] [" "] | grep -Po '<user\s*username=".*?"\s*password=".*?"\s*roles=".*?"\s*/>'`
 if [ "${FIND}" ]; then
  web_admin_tomcat="TRUE"
 else
   web_admin_tomcat="FALSE"
 fi

 if [ "${web_admin_tomcat}" = "TRUE" ]; then
  FIND0=`echo $FIND | grep -Po 'username=".*?"'`
  for j in $FIND0; do
    tmp_username=`echo $j | grep -Po '".*?"'`
    username=`echo ${tmp_username%\"} | cut -c 2-`
    if [ -z "${username}" ]; then
     tom_no_null_username="FALSE"
     break
    fi
  done
 fi
done
else
 tom_no_null_username="NOCHECK"
 nocheck_reason_item49=$tom_users_reason
fi

##################################01-检查是否有重复的Tomcat账号################################################
if [ $tom_users_check != "NOCHECK" ]; then 
for j in ${tom_users_CONFIG}; do 
 tom_users_CONFIG_DOCS=`cat $j | sed '/<!--/{:a;/-->/!{N;ba}};/<!--/d'`
 FIND=`echo ${tom_users_CONFIG_DOCS} | tr ["\n"] [" "] | grep -Po '<user\s*username=".*?"\s*password=".*?"\s*roles=".*?"\s*/>'`
 if [ "${FIND}" ]; then
  web_admin_tomcat="TRUE"
 else
   web_admin_tomcat="FALSE"
 fi

 if [ "${web_admin_tomcat}" = "TRUE" ]; then
  FIND0=`echo $FIND | grep -Po 'username=".*?"' | grep -Po '".*?"' | sort | uniq -c | sort -n | awk '{print $1"="$2;}'`
  for j in $FIND0;do
   username_repeat=`echo $j|awk -F= '{print $1}'`
   if [ $username_repeat -gt 1 ]; then
    tom_username_unique="FALSE"
   fi
  done
 fi
done
else
 tom_username_unique="NOCHECK"
 nocheck_reason_item50=$tom_users_reason
fi

##################################4.3.2 口令###############################################################
##################################01-检查Tomcat管理口令最小长度###############################################
if [ $tom_users_check != "NOCHECK" ]; then 
for j in ${tom_users_CONFIG}; do 
 tom_users_CONFIG_DOCS=`cat $j | sed '/<!--/{:a;/-->/!{N;ba}};/<!--/d'`
 FIND=`echo ${tom_users_CONFIG_DOCS} | tr ["\n"] [" "] | grep -Po '<user\s*username=".*?"\s*password=".*?"\s*roles=".*?"\s*/>'`
 if [ "${FIND}" ]; then
  web_admin_tomcat="TRUE"
 else
   web_admin_tomcat="FALSE"
 fi

 if [ "${web_admin_tomcat}" = "TRUE" ]; then
  FIND0=`echo $FIND | grep -Po 'password=".*?"'`
  for j in $FIND0; do
   tmp_password=`echo $j | grep -Po '".*?"'`
   password=`echo ${tmp_password%\"} | cut -c 2-`
   len=`echo $password |wc -L`
   if [ $len -lt 8 ];then
     tom_password_long_enough="FALSE"
     break
   fi
  done
 fi
done
else
 tom_password_long_enough="NOCHECK"
 nocheck_reason_item51=$tom_users_reason
fi

##################################01-检查Tomcat管理口令组成类型###############################################
if [ $tom_users_check != "NOCHECK" ]; then 
for j in ${tom_users_CONFIG}; do 
 tom_users_CONFIG_DOCS=`cat $j | sed '/<!--/{:a;/-->/!{N;ba}};/<!--/d'`
 FIND=`echo ${tom_users_CONFIG_DOCS} | tr ["\n"] [" "] | grep -Po '<user\s*username=".*?"\s*password=".*?"\s*roles=".*?"\s*/>'`
 if [ "${FIND}" ]; then
  web_admin_tomcat="TRUE"
 else
   web_admin_tomcat="FALSE"
 fi

 if [ "${web_admin_tomcat}" = "TRUE" ]; then 
  FIND0=`echo $FIND | grep -Po 'password=".*?"'`
  for j in $FIND0; do
   tmp_password=`echo $j | grep -Po '".*?"'`
   password=`echo ${tmp_password%\"} | cut -c 2-` 
   lowchar=`echo $password | grep -Po '[a-z]' | wc -l`
   upperchar=`echo $password | grep -Po '[A-Z]' | wc -l`
   digit=`echo $password | grep -Po '[0-9]' | wc -l`
   other=`echo $password | grep -Po '[[:^alnum:]]' | wc -l`
   low_upper_dig_other="$lowchar $upperchar $digit $other"
   password_tpye=`echo $low_upper_dig_other | grep -Po '\s+0' | wc -l` 
   if [ $password_tpye -ge 2 ];then
     tom_password_complex_enough="FALSE"
     break
   fi
  done
 fi
done
else
 tom_password_complex_enough="NOCHECK"
 nocheck_reason_item52=$tom_users_reason
fi

##################################4.3.4 日志###############################################################
##################################01-检查Tomcat是否配置用户登录日志###############################################
if [ $tom_server_check != "NOCHECK" ]; then 
for j in ${tom_server_CONFIG}; do 
 tom_server_CONFIG_DOCS=`cat $j | sed '/<!--/{:a;/-->/!{N;ba}};/<!--/d'`
 FIND=`echo ${tom_server_CONFIG_DOCS} | tr ["\n"] [" "] | grep -Po '<Valve\s*className=\s*"org.apache.catalina.valves.AccessLogValve"\s*directory.*?pattern=\s*"%h\s*%l\s*%u\s*%t\s*&quot;%r&quot;\s*%s\s*%b".*?/>'`
 if [ -z "${FIND}" ]; then
  tom_log_config="FALSE"
 fi
done
else
 tom_log_config="NOCHECK"
 nocheck_reason_item53=$tom_server_reason
fi

##################################4.3.5 其他###############################################################
##################################01-检查Tomcat是否配置账号定时自动退出###############################################
if [ $tom_server_check != "NOCHECK" ]; then 
for j in ${tom_server_CONFIG}; do 
 tom_server_CONFIG_DOCS=`cat $j | sed '/<!--/{:a;/-->/!{N;ba}};/<!--/d'`
 FIND=`echo ${tom_server_CONFIG_DOCS} | tr ["\n"] [" "] | grep -Po '<Connector.*?connectionTimeout=".*?".*?/>'`
 if [ -z "${FIND}" ]; then
  tom_connection_timeout="FALSE"
 fi
done
else
 tom_connection_timeout="NOCHECK"
 nocheck_reason_item54=$tom_server_reason
fi

##################################02-检查是否配置Tomcat错误页面重定向###############################################
if [ $tom_web_check != "NOCHECK" ]; then  
for j in ${tom_web_CONFIG}; do
 tom_web_CONFIG_DOCS=`cat $j | sed '/<!--/{:a;/-->/!{N;ba}};/<!--/d'` 
 FIND=`echo ${tom_web_CONFIG_DOCS} | tr ["\n"] [" "] | grep -Po '<error-page>.*?</error-page>'`
 if [ -z "${FIND}" ]; then
  tom_error_page="FALSE"
 fi
done
else
 tom_error_page="NOCHECK"
 nocheck_reason_item55=$tom_web_reason
fi

##################################03-检查是否禁止Tomcat列表显示文件###############################################
if [ $tom_web_check != "NOCHECK" ]; then  
for j in ${tom_web_CONFIG}; do
 tom_web_CONFIG_DOCS=`cat $j | sed '/<!--/{:a;/-->/!{N;ba}};/<!--/d'` 
 FIND=`echo ${tom_web_CONFIG_DOCS} | tr ["\n"] [" "] | grep -Po '<init-param>\s*<param-name>listings</param-name>\s*<param-value>true</param-value>\s*</init-param>'`
 if [ "${FIND}" ]; then
  forbid_list_tomcat_file="FALSE"
 fi
done
else
 forbid_list_tomcat_file="NOCHECK"
 nocheck_reason_item56=$tom_web_reason
fi


#############################输出json格式体检报告##########################################################
dict_sdavalue=("检查是否有重复的操作系统账号 不应存在相同的操作系统账号 OS-Linux-账号 5 1"
               "检查是否删除或锁定与设备运行、维护等工作无关的账号 所有无关账号都被删除或锁定 OS-Linux-账号 5 1" 
               "检查是否使用PAM认证模块禁止wheel组之外的用户su为root 使用PAM认证模块禁止wheel组之外的用户su为root OS-Linux-账号 5 1"
               "检查/etc/passwd文件权限 -rw-r--r--,-r--r--r-- OS-Linux-授权 5 1"
               "检查/etc/shadow文件权限 -r--------,---------- OS-Linux-授权 5 1"
               "检查/etc/group文件权限 -rw-r--r--,-r--r--r-- OS-Linux-授权 5 1"
               "检查用户目录缺省访问权限设置-UMASK 027 OS-Linux-授权 5 1"
               "检查是否限制FTP用户登录后能访问的目录 限制FTP用户登录后能访问的目录 OS-Linux-授权 5 1"
               "检查口令最小长度 8 OS-Linux-口令 5 1"
               "检查口令组成类型 3 OS-Linux-口令 5 1"
               "检查口令生存周期 90 OS-Linux-口令 5 1"
               "检查syslog是否配置安全事件日志 syslog配置安全事件日志 OS-Linux-日志 2 1"
               "检查系统日志文件是否other用户不可写 系统日志文件other用户不可写 OS-Linux-日志 2 1"
               "检查syslog是否启用记录cron行为日志功能 syslog启用记录cron行为日志功能 OS-Linux-日志 2 1"
               "检查syslog是否配置远程日志功能 syslog配置远程日志功能 OS-Linux-日志 2 1"
               "检查是否禁止root用户telnet远程登录 禁止root用户telnet远程登录 OS-Linux-远程登录 4 1"
               "检查是否禁止root用户SSH远程登录 禁止root用户SSH远程登录 OS-Linux-远程登录 4 1"
               "检查是否配置使用SSH协议 配置使用SSH协议 OS-Linux-远程登录 4 1"
               "检查是否禁止使用telnet协议 禁止使用telnet协议 OS-Linux-远程登录 4 1"
               "检查SSHD是否安全配置 采用V2版本协议，且禁止root登录 OS-Linux-远程登录 4 1"
               "检查是否关闭所有不必要的服务 关闭所有不必要的服务 OS-Linux-不必要的服务 4 1"
               "检查系统banner,避免泄漏操作系统名称,版本号,主机名称等 系统banner,避免泄漏操作系统名称,版本号,主机名称等 OS-Linux-系统Banner设置 3 1"
               "检查是否禁止root登录FTP 禁止root登录FTP OS-Linux-FTP设置 4 1"
               "检查是否禁止匿名登录FTP 禁止匿名登录FTP OS-Linux-FTP设置 4 1"
               "检查系统是否配置定时账号自动登出 系统配置定时账号自动登出 OS-Linux-登录超时时间设置 2 1"
               "检查系统是否含有.rhosts/.netrc/hosts.equiv等危险文件 系统不含.rhosts/.netrc/hosts.equiv等危险文件 OS-Linux-删除潜在危险文件 4 1"
               "检查系统是否以普通账号运行mysqld 系统以mysql账号运行mysqld DB-MySQL-账号 5 $mysql_installed_flag"
               "检查系统是否配置mysql日志 系统至少应配置错误日志、更新日志和二进制日志 DB-MySQL-日志 5 $mysql_installed_flag"
               "检查DBA组中是否只有oracle安装用户 DBA组中只能有oracle安装用户 DB-Oracle-账号 5 $ora_installed_flag"
               "检查是否为Listener的关闭和启动设置密码 应为Listener的关闭和开关设置密码 DB-Oracle-Listener安全 1 $ora_installed_flag"
               "检查是否设置连接超时自动断开 应设置连接超时自动断开 DB-Oracle-连接超时设置 2 $ora_installed_flag"
               "检查是否设置基于IP地址的访问控制 应设置基于IP地址的访问控制 DB-Oracle-可信IP地址访问控制 1 $ora_installed_flag"
               "检查是否加密网络传输数据（可选） 应加密网络传输数据 DB-Oracle-数据传输安全 3 $ora_installed_flag"
               "检查是否以普通用户和组运行nginx 以专门的非root用户账号和组运行nginx Middleware-nginx-账号 5 $nginx_installed_flag"
               "检查是否禁止nginx访问Web目录之外的任何文件 禁止nginx访问Web目录之外的任何文件 Middleware-nginx-授权 5 $nginx_installed_flag"
               "检查是否配置用户登录日志 应配置用户登录日志 Middleware-nginx-日志 2 $nginx_installed_flag"
               "检查是否配置nginx错误页面重定向 应配置nginx错误页面重定向 Middleware-nginx-其他 3 $nginx_installed_flag"
               "检查是否禁止nginx列表显示文件 禁止nginx列表显示文件 Middleware-nginx-其他 3 $nginx_installed_flag"
               "检查是否配置拒绝服务防范 应配置拒绝服务防范 Middleware-nginx-其他 4 $nginx_installed_flag"
               "检查是否隐藏nginx的版本号及其他敏感信息 应隐藏nginx的版本号及其他敏感信息 Middleware-nginx-其他 3 $nginx_installed_flag"
               "检查是否以普通用户和组运行apache 以专门的非root用户账号和组运行Apache Middleware-Apache-账号 5 $apache_installed_flag"
               "检查是否禁止Apache访问Web目录之外的任何文件 禁止Apache访问Web目录之外的任何文件 Middleware-Apache-授权 5 $apache_installed_flag"
               "检查是否配置用户登录日志 应配置用户登录日志 Middleware-Apache-日志 2 $apache_installed_flag"
               "检查是否配置apache错误页面重定向 应配置apache错误页面重定向 Middleware-Apache-其他 3 $apache_installed_flag"
               "检查是否禁止Apache列表显示文件 禁止Apache列表显示文件 Middleware-Apache-其他 3 $apache_installed_flag"
               "检查是否配置拒绝服务防范 应配置拒绝服务防范 Middleware-Apache-其他 4 $apache_installed_flag"
               "检查是否隐藏Apache的版本号及其他敏感信息 应隐藏Apache的版本号及其他敏感信息 Middleware-Apache-其他 3 $apache_installed_flag"
               "检查weblogic管理员是否为root和nobody weblogic管理员不是root和nobody Middleware-WebLogic-账号 5 $weblogic_installed_flag"
               "检查登录weblogic控制台的口令最小长度 8 Middleware-WebLogic-口令 5 $weblogic_installed_flag"
               "检查登录weblogic控制台的口令组成类型 3 Middleware-WebLogic-口令 5 $weblogic_installed_flag"
               "检查是否配置用户登录日志 应配置用户登录日志 Middleware-WebLogic-日志 2 $weblogic_installed_flag"
               "检查Sockets最大打开数目(可选) 数目不大于1024 Middleware-WebLogic-IP协议 4 $weblogic_installed_flag"
               "检查weblogic是否禁用Send-Server-Header(可选) 禁用Send-Server-Header Middleware-WebLogic-IP协议 4 $weblogic_installed_flag"
               "检查weblogic是否配置定时账号自动登出 应配置定时账号自动登出 Middleware-WebLogic-其他 2 $weblogic_installed_flag"
               "检查是否配置weblogic错误页面重定向 应配置weblogic错误页面重定向 Middleware-WebLogic-其他 3 $weblogic_installed_flag"
               "检查是否禁止weblogic列表显示文件 应禁止weblogic列表显示文件 Middleware-WebLogic-其他 3 $weblogic_installed_flag"
               "检查Tomcat管理用户名是否为空 tomcat管理用户名不为空 Middleware-Tomcat-账号 5 $tomcat_installed_flag"
               "检查是否有重复的Tomcat账号 不应存在相同的Tomcat账号 Middleware-Tomcat-账号 5 $tomcat_installed_flag"
               "检查Tomcat管理口令最小长度 8 Middleware-Tomcat-口令 5 $tomcat_installed_flag"
               "检查Tomcat管理口令组成类型 3 Middleware-Tomcat-口令 5 $tomcat_installed_flag"
               "检查Tomcat是否配置用户登录日志 应配置用户登录日志 Middleware-Tomcat-日志 2 $tomcat_installed_flag"
               "检查Tomcat是否配置账号定时自动退出 应配置定时账号自动登出 Middleware-Tomcat-其他 2 $tomcat_installed_flag"
               "检查是否配置Tomcat错误页面重定向 应配置Tomcat错误页面重定向 Middleware-Tomcat-其他 3 $tomcat_installed_flag"
               "检查是否禁止Tomcat列表显示文件 应禁止Tomcat列表显示文件 Middleware-Tomcat-其他 3 $tomcat_installed_flag")
               
dict_words=("$os_username_unique 没有发现重复的用户名 发现重复的用户名 $nocheck_reason_item57"
            "$unrelated_user_lock 没有发现无关用户 未锁定或删除的用户列表:$unrelated_user_unlock $nocheck_reason_item1"
            "$pam_prohibit_nowheel_group_su_root 已正确配置 未正确配置 $nocheck_reason_item2"
            "$etc_passwd_permission 权限:$etc_passwd_permission_config 权限:$etc_passwd_permission_config $nocheck_reason_item3"
            "$etc_shadow_permission 权限:$etc_shadow_permission_config 权限:$etc_shadow_permission_config $nocheck_reason_item4"
            "$etc_group_permission 权限:$etc_group_permission_config 权限:$etc_group_permission_config $nocheck_reason_item5"
            "$check_user_dir_default_accesss_permission 权限:$user_dir_default_accesss_permission_config 权限:$user_dir_default_accesss_permission_config $nocheck_reason_item6"
            "$restrict_ftp_login_dir 已正确配置 未正确配置 $nocheck_reason_item7"
            "$password_min_length $password_min_length_config $password_min_length_config 无法查看/etc/login.defs和PAM文件"
            "$letter_classification $letter_classification_config $letter_classification_config 无法查看PAM文件"
            "$password_expire 超时时间:$password_expire_config 超时时间:$password_expire_config $nocheck_reason_item10"
            "$syslog_rsyslog_syslogn_secure 已正确配置 未正确配置 $nocheck_reason_item11"
            "$var_log_other_unwritable 任何其他用户都不可以写系统日志文件 其他用户可以写的系统日志文件有:$var_log_other_writable $nocheck_reason_item12"
            "$syslog_rsyslog_syslogn_cron 已正确配置 未正确配置 $nocheck_reason_item13"
            "$syslog_rsyslog_syslogn_remotetrans 已正确配置 未正确配置 $nocheck_reason_item14"
            "$root_login_telnet_forbidden 已正确配置 未正确配置 $nocheck_reason_item15"
            "$root_login_ssh_forbidden 已正确配置 未正确配置 $nocheck_reason_item16"
            "$ip_ssh_protocol 已使用SSH协议 未使用SSH协议 $nocheck_reason_item17"
            "$ip_telnet_protocol_forbidden 未使用telnet协议 已使用telnet协议 $nocheck_reason_item18"
            "$sshd_config_secure 已正确配置 未正确配置 $nocheck_reason_item19"
            "$unnessary_service_stop 所有不必要的服务都已被关闭 没有关闭的服务:$unnessary_service_nostop $nocheck_reason_item20"
            "$SYSTEM_BANNER 已正确配置 未正确配置 $nocheck_reason_item21"
            "$forbid_root_login_vsftp 已正确配置 未正确配置 $nocheck_reason_item22"
            "$forbid_anonymous_vsftpd_login 已正确配置 未正确配置 $nocheck_reason_item23"
            "$set_terminal_timeout 超时时间:$terminal_time_config 未正确配置 $nocheck_reason_item24"
            "$danger_file_not_exist 当前用户登录情况下，没有发现危险文件 当前用户登录情况下，存在的危险文件:$danger_file_list $nocheck_reason_item25"
            "$noroot_run_mysqld 系统以默认的mysql账号运行mysqld 系统未安装mysqld $nocheck_reason_item26"
            "$config_log_files_mysqld mysqld已配置错误日志、更新日志和二进制日志 配置的日志类型不够 $nocheck_reason_item27"
            "$only_oracle_belong_dba 已正确配置 DBA组中有oracle安装用户之外的用户 $nocheck_reason_item28"
            "$set_passwd_for_listener_ora 已正确配置 没有为Listener关闭和打开设置密码 $nocheck_reason_item29"
            "$config_expire_time_ora 超时时间:$expire_time 未配置超时自动断开时间 $nocheck_reason_item30"
            "$config_whitelist_based_IP_ora 仅白名单的用户可以访问oracle:$invited_nodes 未设置IP白名单 $nocheck_reason_item31"
            "$config_encryption_ora 加密传输数据 明文传输数据 $nocheck_reason_item32"
            "$noroot_run_nginx 以专门的非root用户账号和组运行nginx 以root用户或root组运行nginx $nocheck_reason_item58"
            "$only_vist_specific_dir_ngn 禁止nginx访问Web目录之外的任何文件 nginx可以访问Web目录之外的文件 $nocheck_reason_item59"
            "$error_access_log_ngn 已正确配置 未正确配置 $nocheck_reason_item60"
            "$error_page_redir_ngn 已正确配置 未正确配置 $nocheck_reason_item61"
            "$forbid_file_list_when_indexhtml_not_exitst_ngn 已正确配置 未正确配置 $nocheck_reason_item62"
            "$anti_DOS_attack_ngn 已正确配置 未正确配置 $nocheck_reason_item63"
            "$sensitive_information_hidden_ngn 已正确配置 未正确配置 $nocheck_reason_item64"
            "$noroot_run_apache 以专门的非root用户账号和组运行Apache 以root用户或root组运行Apache $nocheck_reason_item33"
            "$only_vist_specific_dir_apa 禁止Apache访问Web目录之外的任何文件 Apache可以访问Web目录之外的文件 $nocheck_reason_item34"
            "$error_access_log_apa 已正确配置 未正确配置 $nocheck_reason_item35"
            "$error_page_redir_apa 已正确配置 未正确配置 $nocheck_reason_item36"
            "$forbid_file_list_when_indexhtml_not_exitst_apa 已正确配置 未正确配置 $nocheck_reason_item37"
            "$anti_DOS_attack_apa 已正确配置 未正确配置 $nocheck_reason_item38"
            "$sensitive_information_hidden_apa 已正确配置 未正确配置 $nocheck_reason_item39"
            "$weblogic_admin_not_root 已正确配置 未正确配置 $nocheck_reason_item40"
            "$weblogic_password_long_enough 已正确配置 未正确配置 $nocheck_reason_item41"
            "$weblogic_letter_classification 已正确配置 未正确配置 $nocheck_reason_item42"
            "$weblogic_log_config 已正确配置 未正确配置 $nocheck_reason_item43"
            "$weblogic_max_open_socket_count 已正确配置 未正确配置 $nocheck_reason_item44"
            "$weblogic_send_server_header_forbidden 已正确配置 未正确配置 $nocheck_reason_item45"
            "$weblogic_login_timeout_millis 已正确配置 未正确配置 $nocheck_reason_item46"
            "$weblogic_error_page 已正确配置 未正确配置 $nocheck_reason_item47"
            "$weblogic_index_directory_forbidden 已正确配置 未正确配置 $nocheck_reason_item48"
            "$tom_no_null_username 没有发现空用户名 发现空用户名 $nocheck_reason_item49"
            "$tom_username_unique 没有发现重复的用户名 发现重复的用户名 $nocheck_reason_item50"
            "$tom_password_long_enough 已正确配置 未正确配置 $nocheck_reason_item51"
            "$tom_password_complex_enough 已正确配置 未正确配置 $nocheck_reason_item52"
            "$tom_log_config 已正确配置 未正确配置 $nocheck_reason_item53"
            "$tom_connection_timeout 已正确配置 未正确配置 $nocheck_reason_item54"
            "$tom_error_page 已正确配置 未正确配置 $nocheck_reason_item55"
            "$forbid_list_tomcat_file 已正确配置 未正确配置 $nocheck_reason_item56")






#echo ${dict_words[item24]}
len=${#dict_words[*]}
for (( j=0; j<"$len"; j=j+1 ))
do
 name=`echo ${dict_words[$j]} | awk '{print $1}'`
 pass_words=`echo ${dict_words[$j]} | awk '{print $2}'`
 unpass_words=`echo ${dict_words[$j]} | awk '{print $3}'`
 nocheck_words=`echo ${dict_words[$j]} | awk '{print $4}'`
 if [ $name == "TRUE" ]; then
  dict_result[$j]="pass"
  dict_revalue[$j]=$pass_words
 elif [ $name == "FALSE" ]; then
  dict_result[$j]="unpass"
  dict_revalue[$j]=$unpass_words
 else
  dict_result[$j]="uncheck"
  dict_revalue[$j]=$nocheck_words
 fi
done


host_config="{\"IP_ADDR\": \"$IP_ADDR\", \"MAC_ADDR\": \"$MAC_ADDR\", \"OS_FULLNAME\": \"$OS_FULLNAME\", \"db_type\": ["

for j in $db_type; do
 db_name=`echo $j | awk -F '/' '{print $1}'`
 db_version=`echo $j | awk -F '/' '{print $2}'`
 host_config=$host_config"{\"db_name\": \"$db_name\", \"db_version\": \"$db_version\"},"
done

host_config=`echo ${host_config%,}`
host_config=$host_config"], \"middleware_type\": ["

for j in $middleware_type; do
 middleware_name=`echo $j | awk -F '/' '{print $1}'`
 middleware_version=`echo $j | awk -F '/' '{print $2}'`
 host_config=$host_config"{\"middleware_name\": \"$middleware_name\", \"middleware_version\": \"$middleware_version\"},"
done
host_config=`echo ${host_config%,}`
host_config=$host_config"], "

report_content="\"os_report\": ["
for (( j=0; j<"$len"; j=j+1 ))
do
        show_flag=`echo ${dict_sdavalue[$j]} | awk '{print $5}'`
        checkitem_name=`echo ${dict_sdavalue[$j]} | awk '{print $1}'`
        checkitem_sdavalue=`echo ${dict_sdavalue[$j]} | awk '{print $2}'`
        checkitem_type=`echo ${dict_sdavalue[$j]} | awk '{print $3}'`
        checkitem_level=`echo ${dict_sdavalue[$j]} | awk '{print $4}'`
        checkitem_result=`echo ${dict_result[$j]}`
        checkitem_revalue=`echo ${dict_revalue[$j]}`
        if [ $show_flag -eq 1 ];then
         report_content=$report_content"{\"check_item\": \"$checkitem_name\", \"required_config\": \"$checkitem_sdavalue\", \"check_result\": \"$checkitem_result\", \"actual_config\": \"$checkitem_revalue\", \"item_type\": \"$checkitem_type\", \"threat_level\": \"$checkitem_level\"},"
        fi
done
report_content_json=`echo ${report_content%,}`
report=$host_config$report_content_json"]}"
echo $report