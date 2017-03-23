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
syslogconfs_LOCS="/etc/syslog.conf /etc/rsyslog.conf"
syslog_LOCS="/var/log/boot.log /var/log/secure /var/log/messages /var/log/cron /var/log/spooler /var/log/maillog"
login_LOCS="/etc/pam.d/login"
SSH_DAEMON_CONFIG="/etc/ssh/sshd_config"
require_stop_service="daytime-dgram daytime-stream time-dgram time-stream echo-dgram echo-stream discard-dgram discard-stream chargen-dgram chargen-stream sendmail ntalk ident printer bootps tftp kshell klogin lpd nfs nfslock ypbind"
bannerconfig_LOCS="/etc/issue /etc/issue.net"
BlackUser_LOCS="/etc/vsftpd/ftpusers /etc/ftpusers"
profile_LOCS="/etc/profile"
danger_file=".rhosts .netrc hosts.equiv"
MYSQL_CONFIG_DOCS="/etc/my.cnf"
ORACLE_LISTENER_DIRECTORY=`find / -name *.ora 2>/dev/null | grep -E -i 'oracle.*?listener.ora' | grep -v 'samples'` 
ORACLE_SQLNET_DIRECTORY=`find / -name *.ora 2>/dev/null | grep -E -i 'oracle.*?sqlnet.ora' | grep -v 'samples'`
apache_CONFIG_DOCS="/etc/httpd/conf/httpd.conf"
tom_users_CONFIG=`find / -name tomcat-users.xml 2>/dev/null | grep -E -i 'conf.*?tomcat-users.xml'`
tom_server_CONFIG=`find / -name server.xml 2>/dev/null | grep -E -i 'conf.*?server.xml' | grep -v 'docs'`
tom_web_CONFIG=`find / -name web.xml 2>/dev/null | grep -E -i 'conf.*?web.xml'`
weblogic_config_xml=`find / -name config.xml 2>/dev/null | grep -E -i "/Middleware/.*?/config/"`
weblogic_web_xml=`find / -name web.xml 2>/dev/null | grep -E -i 'Middleware.*?/bea_wls_internal/'`
weblogic_xml=`find / -name weblogic.xml 2>/dev/null | grep -E -i 'Middleware.*?/bea_wls_internal/'`
weblogic_registry_xml=`find / -name registry.xml 2>/dev/null | grep -E -i 'Middleware'`

#########################################################################################
nocheck_reason=(
                 "主机当前用户没有读文件的权限:"
                 "文件不存在:"
                 "主机当前用户不是root用户"
                 "服务未安装:"
                 "服务管理器未安装:"
                 "其他原因"
                )
reason=""
check_status=""
db_type=""
middleware_type=""
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
noroot_run_apache="FALSE"
only_vist_specific_dir_apa="FALSE"
error_access_log_apa="FALSE"
error_page_redir_apa="FALSE"
forbid_file_list_when_indexhtml_not_exitst_apa="TRUE"
anti_DOS_attack_apa="FALSE"
sensitive_information_hidden_apa="FALSE"
weblogic_admin_not_root="TRUE"
weblogic_password_long_enough="FALSE" 
weblogic_letter_classification="FALSE"
i=0
j=0
z=0
weblogic_log_config="FALSE"
weblogic_max_open_socket_count="FALSE" 
weblogic_send_server_header_enabled="FALSE" 
weblogic_login_timeout_millis="TRUE" 
weblogic_error_page="FALSE"
weblogic_index_directory_forbidden="FALSE"
tom_password_long_enough="TRUE"
tom_password_complex_enough="TRUE"
tom_no_null_username="TRUE"
tom_username_unique="TRUE"
tom_error_page="FALSE"
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
 reason=""
 check_status="CHECK"
 str=$2
 str=`echo ${str%,}`
 if [ $1 -eq 0 ]; then
  check_status="NOCHECK"
  reason="$reason${nocheck_reason[3]}$4;"
 elif [ -z "${str}" -o -f "${str}" ]; then
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
    reason="$reason${nocheck_reason[5]};"
   fi
  fi
  nException=FALSE
  trap " " ERR
 fi
}



##################################采集时间##################################################################################
TIMESTAMP=`LC_ALL=C date +%Y-%m-%d\ %H:%M:%S`
##################################主机配置##################################################################################
mysql_installed=`LC_ALL=C ps -e | grep -i mysqld`
ora_installed=`LC_ALL=C ps -e |grep -i oracle`
apache_installed=`LC_ALL=C ps -e |grep -i httpd`
weblogic_installed=`LC_ALL=C ps -e | grep -i weblogic`
tomcat_installed=`LC_ALL=C ps -ef | grep -i tomcat | grep -v 'grep'`

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
 FIND=`echo $ORACLE_HOME 2>/dev/null`
 if [ "${FIND}" ]; then
  version=`echo $FIND | grep -Po -i '/product/.*' | awk -F '/' '{print $3}'`
  db_type=$db_type"oracle/"$version" "
 else
  db_type=$db_type"oracle/- "
 fi
fi

if [ "${apache_installed}" ]; then
 FIND=`httpd -V 2>/dev/null`
 if [ "${FIND}" ]; then
  version=`echo $FIND | grep -i '^Server\s*version:' | awk -F ':' '{print $2}' | awk '{print $1}'`
  middleware_type=$middleware_type$version" "
 else
  middleware_type=$middleware_type"apache/- "
 fi  
fi

if [ "${weblogic_installed}" ]; then
 FIND=`echo $weblogic_registry_xml`
 if [ ! -z "${FIND}" ]; then
  version=`echo $FIND | grep -i 'component name="WebLogic Server"' | grep -Po -i 'version=".*?"' | awk -F '"' '{print $2}'`
  middleware_type=$middleware_type"weblogic/"$version" "
 else
  middleware_type=$middleware_type"weblogic/- "
 fi
fi

if [ "${tomcat_installed}" ]; then
 FIND=`echo $tom_users_CONFIG`
 if [ ! -z "${FIND}" ]; then
  parent_dir=`dirname $(dirname $FIND)`
  dir=$parent_dir"/bin/version.sh"
  command=`sh $dir`
  if [ ! -z "${command}" ]; then
   version=`echo $command | grep -Po -i 'Server\s*version:.*' | awk -F ':' '{print $2}' | awk '{print $2}'`
   middleware_type=$middleware_type$version" "
  else
   middleware_type=$middleware_type"tomcat/- "
  fi
 else
  middleware_type=$middleware_type"tomcat/- "
 fi
fi
###################################配置文件可查性检查#######################################################################
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
file_check $weblogic_installed_flag $weblogic_config_xml, config.xml weblogic
WEBLOGIC_CONFIG_reason=$reason
WEBLOGIC_CONFIG_check=$check_status

file_check $weblogic_installed_flag $weblogic_web_xml, config.xml weblogic
WEBLOGIC_WEB_reason=$reason
WEBLOGIC_WEB_check=$check_status


file_check $weblogic_installed_flag $weblogic_xml, weblogic.xml weblogic
WEBLOGIC_reason=$reason
WEBLOGIC_check=$check_status



if [ "$tomcat_installed" ]; then
  tomcat_installed_flag=1
else
  tomcat_installed_flag=0
fi

file_check $tomcat_installed_flag $tom_users_CONFIG, tomcat-users.xml tomcat
tom_users_reason=$reason
tom_users_check=$check_status

file_check $tomcat_installed_flag $tom_server_CONFIG, server.xml tomcat
tom_server_reason=$reason
tom_server_check=$check_status

file_check $tomcat_installed_flag $tom_web_CONFIG, web.xml tomcat
tom_web_reason=$reason
tom_web_check=$check_status


###########################linux操作系统####################################################################################
###########################4.3.1账号#####################################################
#######################01-是否有重复的操作系统账号#######################################
nocheck_reason_item57=""

trap "nException=TRUE" ERR
cat ${passwd_DOCS} >/dev/null 2>/dev/null
if [ $nException == "TRUE" ]; then
 if [ ! -f "${passwd_DOCS}" ]; then
  os_username_unique="NOCHECK"
  nocheck_reason_item57="$nocheck_reason_item57${nocheck_reason[1]}${passwd_DOCS};"
 fi
 if [ ! -r "${passwd_DOCS}" ]; then
  os_username_unique="NOCHECK"
  nocheck_reason_item57="$nocheck_reason_item57${nocheck_reason[0]}${passwd_DOCS};"
 else
  os_username_unique="NOCHECK"
  nocheck_reason_item57="$nocheck_reason_item57${nocheck_reason[5]};"
 fi
fi
nException=FALSE
trap " " ERR

if [ $os_username_unique != "NOCHECK" ]; then
 FIND=`cat ${passwd_DOCS} | awk -F ':' '{print $1}' | sort | uniq -c | sort -n | awk '{print $1"="$2;}'`
 for j in $FIND0;do
   username_repeat=`echo $j|awk -F= '{print $1}'`
   if [ $username_repeat -gt 1 ]; then
    os_username_unique="FALSE"
   fi
  done
fi


#######################02-是否删除或锁定与设备运行、维护等工作无关的账号#################
nocheck_reason_item1=""
userid=`id -u $user`
if [ $USER != "root" -a $userid -ne 0 ]; then
 unrelated_user_lock="NOCHECK"
 nocheck_reason_item1="$nocheck_reason_item1${nocheck_reason[2]};"
fi

trap "nException=TRUE" ERR
cat ${passwd_DOCS} >/dev/null 2>/dev/null
if [ $nException == "TRUE" ]; then
 if [ ! -f "${passwd_DOCS}" ]; then
  unrelated_user_lock="NOCHECK"
  nocheck_reason_item1="$nocheck_reason_item1${nocheck_reason[1]}${passwd_DOCS};"
 fi
 
 if [ ! -r "${passwd_DOCS}" ]; then
  unrelated_user_lock="NOCHECK"
  nocheck_reason_item1="$nocheck_reason_item1${nocheck_reason[0]}${passwd_DOCS};"
 else
  unrelated_user_lock="NOCHECK"
  nocheck_reason_item1="$nocheck_reason_item1${nocheck_reason[5]};"
 fi
fi
 nException=FALSE
 trap " " ERR

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
nocheck_reason_item2=""

trap "nException=TRUE" ERR
cat ${su_DOCS} >/dev/null 2>/dev/null
if [ $nException == "TRUE" ]; then
 if [ ! -f "${su_DOCS}" ]; then
  pam_prohibit_nowheel_group_su_root="NOCHECK"
  nocheck_reason_item2="$nocheck_reason_item2${nocheck_reason[1]}${su_DOCS};"
 fi
 if [ ! -r "${su_DOCS}" ]; then
  pam_prohibit_nowheel_group_su_root="NOCHECK"
  nocheck_reason_item2="$nocheck_reason_item2${nocheck_reason[0]}${su_DOCS};"
 else
  pam_prohibit_nowheel_group_su_root="NOCHECK"
  nocheck_reason_item2="$nocheck_reason_item2${nocheck_reason[5]};"
 fi
fi
nException=FALSE
trap " " ERR

if [ $pam_prohibit_nowheel_group_su_root != "NOCHECK" ]; then
 FIND=`cat ${su_DOCS} | grep -E -i '^(auth\s*sufficient\s*pam_rootok.so|auth\s*required\s*pam_wheel.so\s*group=wheel)' |wc -l`
 if [ $FIND -eq 2 ]; then
  pam_prohibit_nowheel_group_su_root="TRUE"
 fi
fi

#############################4.3.2授权######################################################
#######################01-检查/etc/passwd文件权限###########################################
nocheck_reason_item3=""

if [ ! -f "${passwd_DOCS}" ]; then
 etc_passwd_permission="NOCHECK"
 nocheck_reason_item3="$nocheck_reason_item3${nocheck_reason[1]}${passwd_DOCS};"
fi

if [ $etc_passwd_permission != "NOCHECK" ]; then
 FIND=`LC_ALL=C ls -l ${passwd_DOCS} | awk '{print $1}'`
 if [ "${FIND}" == "-rw-r--r--." -o "${FIND}" == "-r--r--r--." ]; then
  etc_passwd_permission="TRUE"
 fi
 etc_passwd_permission_config=$FIND
fi

#######################01-检查/etc/shadow文件权限############################################
nocheck_reason_item4=""

if [ ! -f "${shadow_DOCS}" ]; then
 etc_shadow_permission="NOCHECK"
 nocheck_reason_item4="$nocheck_reason_item4${nocheck_reason[1]}${shadow_DOCS};"
fi

if [ $etc_shadow_permission != "NOCHECK" ]; then
 FIND=`LC_ALL=C ls -l ${shadow_DOCS} | awk '{print $1}'`
 if [ "${FIND}" == "-r--------." -o "${FIND}" == "----------." ]; then
  etc_shadow_permission="TRUE"
 fi
 etc_shadow_permission_config=$FIND
fi
#######################01-检查/etc/group文件权限############################################
nocheck_reason_item5=""

if [ ! -f "${group_DOCS}" ]; then
 etc_group_permission="NOCHECK"
 nocheck_reason_item5="$nocheck_reason_item5${nocheck_reason[1]}${group_DOCS};"
fi

if [ $etc_group_permission != "NOCHECK" ]; then
 FIND=`LC_ALL=C ls -l ${group_DOCS} | awk '{print $1}'`
 if [ "${FIND}" == "-rw-r--r--." -o "${FIND}" == "-r--r--r--." ]; then
  etc_group_permission="TRUE"
 fi
 etc_group_permission_config=$FIND
fi

#######################02-检查用户目录缺省访问权限设置########################################
nocheck_reason_item6=""

trap "nException=TRUE" ERR
cat ${logindefs_DOCS} >/dev/null 2>/dev/null
if [ $nException == "TRUE" ]; then
 if [ ! -f "${logindefs_DOCS}" ]; then
  check_user_dir_default_accesss_permission="NOCHECK"
  nocheck_reason_item6="$nocheck_reason_item6${nocheck_reason[1]}${logindefs_DOCS};"
 fi
 if [ ! -r "${logindefs_DOCS}" ]; then
  check_user_dir_default_accesss_permission="NOCHECK"
  nocheck_reason_item6="$nocheck_reason_item6${nocheck_reason[0]}${logindefs_DOCS};"
 else
  check_user_dir_default_accesss_permission="NOCHECK"
  nocheck_reason_item6="$nocheck_reason_item6${nocheck_reason[5]};"
 fi
fi
nException=FALSE
trap " " ERR

if [ $check_user_dir_default_accesss_permission != "NOCHECK" ]; then
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
fi
#######################03-检查是否限制FTP用户登录后能访问的目录##################################
nocheck_reason_item7=""
if [ -z "${vsftp_DAEMON_CONFIG}" ]; then
 restrict_ftp_login_dir="NOCHECK"
 nocheck_reason_item7="$nocheck_reason_item7${nocheck_reason[3]}vsftp;"
else
 trap "nException=TRUE" ERR
 cat ${vsftp_DAEMON_CONFIG} >/dev/null 2>/dev/null
 if [ $nException == "TRUE" ]; then
  if [ ! -r "${vsftp_DAEMON_CONFIG}" ]; then
   restrict_ftp_login_dir="NOCHECK"
   nocheck_reason_item7="$nocheck_reason_item7${nocheck_reason[0]}${vsftp_DAEMON_CONFIG};"
  else
   restrict_ftp_login_dir="NOCHECK"
   nocheck_reason_item7="$nocheck_reason_item7${nocheck_reason[5]};"
  fi
 fi
 nException=FALSE
 trap " " ERR
fi

if [ $restrict_ftp_login_dir != "NOCHECK" ]; then
 FIND=`cat ${vsftp_DAEMON_CONFIG} | grep -E -i '^(chroot_local_user=YES|#chroot_local_user=YES)' |wc -l`  
 if [ $FIND -eq 1 ]; then
  restrict_ftp_login_dir="TRUE"
 fi 
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
done
nException=FALSE
trap " " ERR

if [ $logindefs_check == "NOCHECK" -a $PAM_check == "FALSE" ];then
 password_min_length="NOCHECK"
fi


if [ $logindefs_check != "NOCHECK" ];then
 FIND=`cat ${logindefs_DOCS} | grep -E -i '^PASS_MIN_LEN' | awk '{print $2}'`
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
done
nException=FALSE
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
nocheck_reason_item10=""

trap "nException=TRUE" ERR
cat ${logindefs_DOCS} >/dev/null 2>/dev/null
if [ $nException == "TRUE" ]; then
 if [ ! -f "${logindefs_DOCS}" ]; then
  password_expire="NOCHECK"
  nocheck_reason_item10="$nocheck_reason_item10${nocheck_reason[1]}${logindefs_DOCS};"
 fi
 if [ ! -r "${logindefs_DOCS}" ]; then
  password_expire="NOCHECK"
  nocheck_reason_item10="$nocheck_reason_item10${nocheck_reason[0]}${logindefs_DOCS};"
 else
  password_expire="NOCHECK"
  nocheck_reason_item10="$nocheck_reason_item10${nocheck_reason[5]};"
 fi
fi
nException=FALSE
trap " " ERR

if [ $password_expire != "NOCHECK" ]; then
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
fi

#############################4.3.4日志############################################################
#######################01-检查syslog是否配置安全事件日志##########################################
nocheck_reason_item11=""

if [ -z "${SYSLOG_CONFIG}" ]; then
  syslog_rsyslog_syslogn_secure="NOCHECK"
  nocheck_reason_item11="$nocheck_reason_item11${nocheck_reason[1]}syslog.conf或rsyslog.conf;"
else
 trap "nException=TRUE" ERR
 cat ${SYSLOG_CONFIG} >/dev/null 2>/dev/null
 if [ $nException == "TRUE" ]; then
  if [ ! -r "${SYSLOG_CONFIG}" ]; then
   syslog_rsyslog_syslogn_secure="NOCHECK"
   nocheck_reason_item11="$nocheck_reason_item11${nocheck_reason[0]}${SYSLOG_CONFIG};"
  else
   syslog_rsyslog_syslogn_secure="NOCHECK"
   nocheck_reason_item11="$nocheck_reason_item11${nocheck_reason[5]};"
  fi
 fi
 nException=FALSE
 trap " " ERR
fi

if [ $syslog_rsyslog_syslogn_secure != "NOCHECK" ]; then
FIND=`cat ${SYSLOG_CONFIG} | grep -E -i '^(authpriv.*\s*/var/log/secure)'`
if [ "${FIND}" ]; then
  syslog_rsyslog_syslogn_secure="TRUE"
fi
fi

#######################02-检查系统日志文件是否other用户不可写######################################
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
   
#######################03-syslog是否启用记录cron行为日志功能#########################################
nocheck_reason_item13=""

if [ -z "${SYSLOG_CONFIG}" ]; then
  syslog_rsyslog_syslogn_cron="NOCHECK"
  nocheck_reason_item13="$nocheck_reason_item13${nocheck_reason[1]}syslog.conf或rsyslog.conf;"
else
 trap "nException=TRUE" ERR
 cat ${SYSLOG_CONFIG} >/dev/null 2>/dev/null
 if [ $nException == "TRUE" ]; then
  if [ ! -r "${SYSLOG_CONFIG}" ]; then
   syslog_rsyslog_syslogn_cron="NOCHECK"
   nocheck_reason_item13="$nocheck_reason_item13${nocheck_reason[0]}${SYSLOG_CONFIG};"
  else
   syslog_rsyslog_syslogn_cron="NOCHECK"
   nocheck_reason_item13="$nocheck_reason_item13${nocheck_reason[5]};"
  fi
 fi
 nException=FALSE
 trap " " ERR
fi

if [ $syslog_rsyslog_syslogn_cron != "NOCHECK" ]; then
FIND=`cat ${SYSLOG_CONFIG} | grep -E -i '^(cron.*\s*/var/log/cron)'`
if [ "${FIND}" ]; then
  syslog_rsyslog_syslogn_cron="TRUE"
fi
fi

#######################04-syslog是否配置远程日志功能##################################################
nocheck_reason_item14=""

if [ -z "${SYSLOG_CONFIG}" ]; then
  syslog_rsyslog_syslogn_remotetrans="NOCHECK"
  nocheck_reason_item14="$nocheck_reason_item14${nocheck_reason[1]}syslog.conf或rsyslog.conf;"
else
 trap "nException=TRUE" ERR
 cat ${SYSLOG_CONFIG} >/dev/null 2>/dev/null
 if [ $nException == "TRUE" ]; then 
  if [ ! -r "${SYSLOG_CONFIG}" ]; then
   syslog_rsyslog_syslogn_remotetrans="NOCHECK"
   nocheck_reason_item14="$nocheck_reason_item14${nocheck_reason[0]}${SYSLOG_CONFIG};"
  else
   syslog_rsyslog_syslogn_remotetrans="NOCHECK"
   nocheck_reason_item14="$nocheck_reason_item14${nocheck_reason[5]};"
  fi
 fi
 nException=FALSE
 trap " " ERR
fi

if [ $syslog_rsyslog_syslogn_remotetrans != "NOCHECK" ]; then
FIND=`cat ${SYSLOG_CONFIG} |  grep -v '^#' | grep '@'`
if [ "${FIND}" ]; then
  syslog_rsyslog_syslogn_remotetrans="TRUE"
fi
fi

#############################4.3.5远程登录############################################################
#######################01-检查是否禁止root用户telnet远程登录##########################################
nocheck_reason_item15=""

trap "nException=TRUE" ERR
cat ${login_LOCS} >/dev/null 2>/dev/null
if [ $nException == "TRUE" ]; then
 if [ ! -f "${login_LOCS}" ]; then
  root_login_telnet_forbidden="NOCHECK"
  nocheck_reason_item15="$nocheck_reason_item15${nocheck_reason[1]}${login_LOCS};"
 fi
 if [ ! -r "${login_LOCS}" ]; then
  root_login_telnet_forbidden="NOCHECK"
  nocheck_reason_item15="$nocheck_reason_item15${nocheck_reason[0]}${login_LOCS};"
 else
  root_login_telnet_forbidden="NOCHECK"
  nocheck_reason_item15="$nocheck_reason_item15${nocheck_reason[5]};"
 fi
fi
nException=FALSE
trap " " ERR

if [ $root_login_telnet_forbidden != "NOCHECK" ]; then
FIND=`cat ${login_LOCS} |grep -E -i '^auth\s*required\s*pam_securetty.so'`
if [ "${FIND}" ]; then
  root_login_telnet_forbidden="TRUE"
fi
fi

#######################01-检查是否禁止root用户ssh远程登录##############################################
nocheck_reason_item16=""

trap "nException=TRUE" ERR
cat ${SSH_DAEMON_CONFIG} >/dev/null 2>/dev/null
if [ $nException == "TRUE" ]; then
 if [ ! -f "${SSH_DAEMON_CONFIG}" ]; then
  root_login_ssh_forbidden="NOCHECK"
  nocheck_reason_item16="$nocheck_reason_item16${nocheck_reason[3]}ssh;"
 fi
 if [ ! -r "${SSH_DAEMON_CONFIG}" ]; then
  root_login_ssh_forbidden="NOCHECK"
  nocheck_reason_item16="$nocheck_reason_item16${nocheck_reason[0]}${SSH_DAEMON_CONFIG};"
 else
  root_login_ssh_forbidden="NOCHECK"
  nocheck_reason_item16="$nocheck_reason_item16${nocheck_reason[5]};"
 fi
fi
nException=FALSE
trap " " ERR

if [ $root_login_ssh_forbidden != "NOCHECK" ]; then
 FIND=`cat ${SSH_DAEMON_CONFIG} |grep -E -i '^PermitRootLogin\s*no'`
 if [ "${FIND}" ]; then
  root_login_ssh_forbidden="TRUE"
 fi
fi

##########02-检查使用IP协议进行远程维护的设备,是否配置使用SSH协议########################################
FIND=`LC_ALL=C ps -e | grep -i 'sshd'`
if [ "${FIND}" ]; then
  ip_ssh_protocol="TRUE"
fi
##########02-检查使用IP协议进行远程维护的设备,是否禁止使用telnet协议######################################
nocheck_reason_item18=""

trap "nException=TRUE" ERR
chkconfig --list >/dev/null 2>/dev/null
if [ $nException == "TRUE" ]; then
 ip_telnet_protocol_forbidden="NOCHECK"
 nocheck_reason_item18="$nocheck_reason_item18${nocheck_reason[4]}chkconfig;"
fi
nException=FALSE
trap " " ERR

if [ $ip_telnet_protocol_forbidden != "NOCHECK" ]; then
FIND=`LC_ALL=C chkconfig --list | grep -E -i 'on' | grep -i 'telnet:'`
if [ "${FIND}" ]; then
  ip_telnet_protocol_forbidden="FALSE"
fi
fi

##########02-检查使用IP协议进行远程维护的设备,是否安全配置SSHD############################################
nocheck_reason_item19=""

trap "nException=TRUE" ERR
cat ${SSH_DAEMON_CONFIG} >/dev/null 2>/dev/null
if [ $nException == "TRUE" ]; then
 if [ ! -f "${SSH_DAEMON_CONFIG}" ]; then
  sshd_config_secure="NOCHECK"
  nocheck_reason_item19="$nocheck_reason_item19${nocheck_reason[3]}ssh;"
 fi
 if [ ! -r "${SSH_DAEMON_CONFIG}" ]; then
  sshd_config_secure="NOCHECK"
  nocheck_reason_item19="$nocheck_reason_item19${nocheck_reason[0]}${SSH_DAEMON_CONFIG};"
 else
  sshd_config_secure="NOCHECK"
  nocheck_reason_item19="$nocheck_reason_item19${nocheck_reason[5]};"
 fi
fi
nException=FALSE
trap " " ERR

if [ $sshd_config_secure != "NOCHECK" ]; then
 FIND=`cat ${SSH_DAEMON_CONFIG} | grep -E -i '^(Protocol\s*2|#Protocol\s*2|PermitRootLogin\s*no)' |wc -l`  
 if [ $FIND -eq 2 ]; then
  sshd_config_secure="TRUE"
 fi
fi

#############################4.3.7不必要的服务##########################################################
#######################01-关闭不必要的服务##############################################################
nocheck_reason_item20=""

trap "nException=TRUE" ERR
chkconfig --list >/dev/null 2>/dev/null
if [ $nException == "TRUE" ]; then
 unnessary_service_stop="NOCHECK"
 nocheck_reason_item20="$nocheck_reason_item20${nocheck_reason[4]}chkconfig;"
fi
nException=FALSE
trap " " ERR

if [ $unnessary_service_stop != "NOCHECK" ]; then
for I in ${require_stop_service}; do  
 FIND=`LC_ALL=C chkconfig --list | grep ${I}" " | grep -E -i 'on'`
 FIND1=`LC_ALL=C chkconfig --list | grep ${I}":" | grep -E -i 'on'`
 if [ "${FIND}" -o "${FIND1}" ]; then 
  unnessary_service_stop="FALSE"
  unnessary_service_nostop=$unnessary_service_nostop"${I};"
 fi
done
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
   nocheck_reason_item22="$nocheck_reason_item22${nocheck_reason[5]};"
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
   nocheck_reason_item22="$nocheck_reason_item22${nocheck_reason[5]};"
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
   nocheck_reason_item22="$nocheck_reason_item22${nocheck_reason[5]};"
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
nocheck_reason_item23=""

if [ -z "${vsftp_DAEMON_CONFIG}" ]; then
  forbid_anonymous_vsftpd_login="NOCHECK"
  nocheck_reason_item23="$nocheck_reason_item23${nocheck_reason[3]}vsftp;"
else
 trap "nException=TRUE" ERR
 cat ${vsftp_DAEMON_CONFIG} >/dev/null 2>/dev/null
 if [ $nException == "TRUE" ]; then
  if [ ! -r "${vsftp_DAEMON_CONFIG}" ]; then
   forbid_anonymous_vsftpd_login="NOCHECK"
   nocheck_reason_item23="$nocheck_reason_item23${nocheck_reason[0]}${vsftp_DAEMON_CONFIG};"
  else
   forbid_anonymous_vsftpd_login="NOCHECK"
   nocheck_reason_item23="$nocheck_reason_item23${nocheck_reason[5]};"
  fi
 fi
 nException=FALSE
 trap " " ERR
fi

if [ $forbid_anonymous_vsftpd_login != "NOCHECK" ]; then 
 FIND=`cat ${vsftp_DAEMON_CONFIG} | grep -E -i "^anonymous_enable=NO"`
 if [ "${FIND}" ]; then
  forbid_anonymous_vsftpd_login="TRUE"
 fi
fi

#############################4.3.10 登录超时时间设置####################################################
################################01-检查系统是否配置定时账号自动登出#####################################
nocheck_reason_item24=""

trap "nException=TRUE" ERR
cat ${profile_LOCS} >/dev/null 2>/dev/null
if [ $nException == "TRUE" ]; then
 if [ ! -f "${profile_LOCS}" ]; then
  set_terminal_timeout="NOCHECK"
  nocheck_reason_item24="$nocheck_reason_item24${nocheck_reason[1]}${profile_LOCS};"
 fi
 if [ ! -r "${profile_LOCS}" ]; then
  set_terminal_timeout="NOCHECK"
  nocheck_reason_item24="$nocheck_reason_item24${nocheck_reason[0]}${profile_LOCS};"
 else
  set_terminal_timeout="NOCHECK"
  nocheck_reason_item24="$nocheck_reason_item24${nocheck_reason[5]};"
 fi
fi
nException=FALSE
trap " " ERR

if [ $set_terminal_timeout != "NOCHECK" ]; then 
FIND=`cat ${profile_LOCS} | grep -v '^#' | grep -i 'TMOUT='`
if [ "${FIND}" ]; then
  set_terminal_timeout="TRUE"
  terminal_time_config=$FIND
else
 terminal_time_config="未正确配置"
fi
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

trap "nException=TRUE" ERR
cat ${group_DOCS} >/dev/null 2>/dev/null
if [ $nException == "TRUE" ]; then
 if [ ! -f "${group_DOCS}" ]; then
  only_oracle_belong_dba="NOCHECK"
  nocheck_reason_item28="$nocheck_reason_item28${nocheck_reason[1]}${group_DOCS};"
 fi
 if [ ! -r "${group_DOCS}" ]; then
  only_oracle_belong_dba="NOCHECK"
  nocheck_reason_item28="$nocheck_reason_item28${nocheck_reason[0]}${group_DOCS};"
 else
  only_oracle_belong_dba="NOCHECK"
  nocheck_reason_item28="$nocheck_reason_item28${nocheck_reason[5]};"
 fi
fi
nException=FALSE
trap " " ERR

trap "nException=TRUE" ERR
cat ${passwd_DOCS} >/dev/null 2>/dev/null
if [ $nException == "TRUE" ]; then
 if [ ! -f "${passwd_DOCS}" ]; then
  only_oracle_belong_dba="NOCHECK"
  nocheck_reason_item28="$nocheck_reason_item28${nocheck_reason[1]}${passwd_DOCS};"
 fi
 if [ ! -r "${passwd_DOCS}" ]; then
  only_oracle_belong_dba="NOCHECK"
  nocheck_reason_item28="$nocheck_reason_item28${nocheck_reason[0]}${passwd_DOCS};"
 else
  only_oracle_belong_dba="NOCHECK"
  nocheck_reason_item28="$nocheck_reason_item28${nocheck_reason[5]};"
 fi
fi
nException=FALSE
trap " " ERR


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

############################Apache###################################################################################
############################4.2.1 账号#################################################
############################01-检查是否以普通用户和组运行apache################################
nocheck_reason_item33=""

trap "nException=TRUE" ERR
cat ${apache_CONFIG_DOCS} >/dev/null 2>/dev/null
if [ $nException == "TRUE" ]; then
 if [ ! -f "${apache_CONFIG_DOCS}" ]; then
  noroot_run_apache="NOCHECK"
  nocheck_reason_item33="$nocheck_reason_item33${nocheck_reason[1]}${apache_CONFIG_DOCS};"
 fi
 if [ ! -r "${apache_CONFIG_DOCS}" ]; then
  noroot_run_apache="NOCHECK"
  nocheck_reason_item33="$nocheck_reason_item33${nocheck_reason[0]}${apache_CONFIG_DOCS};"
 else
  noroot_run_apache="NOCHECK"
  nocheck_reason_item33="$nocheck_reason_item33${nocheck_reason[5]};"
 fi
fi
nException=FALSE
trap " " ERR

if [ $noroot_run_apache != "NOCHECK" ]; then 
FIND=`cat ${apache_CONFIG_DOCS} | grep -i '^User.*'| awk '{print $2}'`
FIND1=`cat ${apache_CONFIG_DOCS} | grep -i '^Group.*'| awk '{print $2}'`
if [ "$FIND" != "root" -a "$FIND1" != "root" ]; then
 noroot_run_apache="TRUE"
fi
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
 FIND=`cat ${weblogic_config_xml} | tr ["\n"] [" "] | grep -Po '<node-manager-username>.*?</node-manager-username>' | awk -F '<' '{print $2}' | awk -F '>' '{print $2}'`
 for I in ${FIND}; do
  if [ "${FIND}" = "root" -o "${FIND}" = "nobody" ]; then
   weblogic_admin_not_root="FALSE"
  fi
 done
else
  weblogic_admin_not_root="NOCHECK"
  nocheck_reason_item40=$WEBLOGIC_CONFIG_reason 
fi

############################4.7.2 口令############################################################
############################01-检查weblogic口令长度###############################################
if [ $WEBLOGIC_CONFIG_check != "NOCHECK" ]; then 
 FIND=`cat ${weblogic_config_xml} | tr ["\n"] [" "] | grep -Po '<sec:password-validator.*?<sec:name>SystemPasswordValidator</sec:name>.*?</sec:password-validator>'`
 FIND1=`echo ${FIND} | grep -Po '<pas:min-password-length>[0-9]*?</pas:min-password-length>' | awk -F '<' '{print $2}' | awk -F '>' '{print $2}'`
 if [ "${FIND1}" ]; then
  min_password_length=$((10#${FIND1}))
  if [ $min_password_length -ge 8 ]; then
     weblogic_password_long_enough="TRUE" 
  fi
 fi
else
 weblogic_password_long_enough="NOCHECK"
 nocheck_reason_item41=$WEBLOGIC_CONFIG_reason 
fi

###################################01-weblogic口令类型###########################################
if [ $WEBLOGIC_CONFIG_check != "NOCHECK" ]; then 
 FIND=`cat ${weblogic_config_xml} | tr ["\n"] [" "] | grep -Po '<sec:password-validator.*?<sec:name>SystemPasswordValidator</sec:name>.*?</sec:password-validator>'`
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

 if [ $weblogic_min_alphabetic_characters -eq 0 ]; then
   z=$(($z+1))
 fi
 if [ $weblogic_min_numeric_characters -eq 0 ]; then
   i=$(($i+1))
   z=$(($z+1))
 fi
 if [ $weblogic_min_lowercase_characters -eq 0 ]; then
    i=$(($i+1))
    j=$(($j+1))
 fi
 if [ $weblogic_min_uppercase_characters -eq 0 ]; then
    i=$(($i+1))
    j=$(($j+1))
 fi
 if [ $weblogic_min_non_alphanumeric_characters -eq 0 ]; then
    i=$(($i+1))
    z=$(($z+1))
 fi
 if [ $weblogic_min_numeric_or_special_characters -eq 0 ]; then
    j=$(($j+1))
 fi

 if [ $i -le 1 -o $j -eq 0 -o $z -eq 0 ]; then
   weblogic_letter_classification="TRUE"
 fi
else
 weblogic_letter_classification="NOCHECK"
 nocheck_reason_item42=$WEBLOGIC_CONFIG_reason 
fi

############################4.7.4 日志############################################################
########################################01-检查是否配置用户登录日志###############################
if [ $WEBLOGIC_CONFIG_check != "NOCHECK" ]; then 
 FIND=`cat ${weblogic_config_xml} | tr ["\n"] [" "] | grep -Po '<web-server-log>.*?</web-server-log>'`
 FIND1=`echo ${FIND} | grep -Po '<log-file-format>.*?</log-file-format>' | awk -F '<' '{print $2}' | awk -F '>' '{print $2}'`
 if [ -z "${FIND1}" ]; then
  FIND1="common"
 fi

 if [ "${FIND1}" = "common" ]; then
  weblogic_log_config="TRUE"
 else
  FIND2=`echo ${FIND} | grep -Po '<elf-fields>.*?</elf-fields>' | awk -F '<' '{print $2}' | awk -F '>' '{print $2}'`
  if [ -z "${FIND2}" ]; then
   FIND2="date time cs-method cs-uri sc-status"
  fi
  FIND0=`echo ${FIND2} | grep date | grep time | grep cs-method | grep sc-status | grep c-ip`
  if [ "${FIND0}" ]; then
   weblogic_log_config="TRUE"
  fi
 fi
else
 weblogic_log_config="NOCHECK"
 nocheck_reason_item43=$WEBLOGIC_CONFIG_reason 
fi

############################4.7.5 IP协议###########################################################
########################################01-检查Sockets最大打开数目(可选)###########################
if [ $WEBLOGIC_CONFIG_check != "NOCHECK" ]; then 
 FIND=`cat ${weblogic_config_xml} | tr ["\n"] [" "] | grep -Po '<max-open-sock-count>.*?</max-open-sock-count>' | awk -F '<' '{print $2}' | awk -F '>' '{print $2}'`
 if [ -z "${FIND}" ]; then
  FIND="-1"
 fi
 max_open_sock_count=$((10#${FIND}))

 if [ $max_open_sock_count -le 1024 -a $max_open_sock_count -gt 0 ]; then
     weblogic_max_open_socket_count="TRUE" 
 fi
else
 weblogic_max_open_socket_count="NOCHECK"
 nocheck_reason_item44=$WEBLOGIC_CONFIG_reason
fi

########################################02-检查weblogic是否禁用Send-Server-Header(可选)#############
if [ $WEBLOGIC_CONFIG_check != "NOCHECK" ]; then 
 FIND=`cat ${weblogic_config_xml} | tr ["\n"] [" "] | grep -Po '<send-server-header-enabled>.*?</send-server-header-enabled>'`
 if [ -z "${FIND}" ]; then
  FIND="false"
 fi
 if [ "$FIND" = "false" ]; then
    weblogic_send_server_header_enabled="TRUE" 
 fi
else
 weblogic_send_server_header_enabled="NOCHECK"
 nocheck_reason_item45=$WEBLOGIC_CONFIG_reason
fi

############################4.7.5 其他###############################################################
########################################01-检查weblogic是否配置定时账号自动登出######################
if [ $WEBLOGIC_CONFIG_check != "NOCHECK" ]; then 
 FIND=`cat ${weblogic_config_xml} | tr ["\n"] [" "] | grep -Po '<login-timeout-millis>.*?</login-timeout-millis>'`
 FIND1=`echo ${FIND} | awk -F '<' '{print $2}' | awk -F '>' '{print $2}'`
 if [ "${FIND1}" ]; then
  login_timeout_millis=$((10#${FIND1}))
  if [ $login_timeout_millis -eq 0 ]; then
     weblogic_login_timeout_millis="FALSE" 
  fi
 fi
else
 weblogic_login_timeout_millis="NOCHECK"
 nocheck_reason_item46=$WEBLOGIC_CONFIG_reason
fi

########################################02-检查是否配置weblogic错误页面重定向#########################
if [ $WEBLOGIC_WEB_check != "NOCHECK" ]; then 
 FIND=`cat ${weblogic_web_xml} | tr ["\n"] [" "] | grep -Po '<error-page>.*?</error-page>'`
 if [ "${FIND}" ]; then
  weblogic_error_page="TRUE"
 fi
else
 weblogic_error_page="NOCHECK"
 nocheck_reason_item47=$WEBLOGIC_WEB_reason
fi

########################################03-检查是否禁止weblogic列表显示文件############################
if [ $WEBLOGIC_CONFIG_check != "NOCHECK" ]; then 
 FIND=`cat ${weblogic_config_xml} | tr ["\n"] [" "] | grep -Po '<index-directory-enabled>.*?</index-directory-enabled>'`
 if [ -z "${FIND}" ]; then
  FIND="false"
 fi
else
 FIND="nocheck"
fi

if [ $WEBLOGIC_check != "NOCHECK" ]; then 
 FIND1=`cat ${weblogic_xml} | tr ["\n"] [" "] | grep -Po '<index-directory-enabled>.*?</index-directory-enabled>'`
 if [ -z "${FIND1}" ]; then
  FIND1="false"
 fi
else
 FIND1="nocheck"
fi

if [ "$FIND" = "false" -o "$FIND1" = "false" ]; then
  weblogic_index_directory_forbidden="TRUE"
elif [ "$FIND" = "nocheck" -a "$FIND1" = "nocheck" ]; then
  weblogic_index_directory_forbidden="NOCHECK"
  nocheck_reason_item48=$WEBLOGIC_reason$WEBLOGIC_CONFIG_reason
fi

##################################Tomcat#################################################################################
##################################4.3.1 账号###############################################################
##################################01-检查Tomcat账号是否为空###################################################
if [ $tom_users_check != "NOCHECK" ]; then 
 tom_users_CONFIG_DOCS=`cat ${tom_users_CONFIG} | sed '/<!--/{:a;/-->/!{N;ba}};/<!--/d'`
 FIND=`echo ${tom_users_CONFIG_DOCS} | tr ["\n"] [" "] | grep -Po '<user\s*username=".*?"\s*password=".*?"\s*roles=".*?"\s*/>'`
 if [ "${FIND}" ]; then
  web_admin_tomcat="FALSE"
 else
   web_admin_tomcat="TRUE"
 fi

 if [ "${web_admin_tomcat}" = "TRUE" ]; then
  FIND0=`echo $FIND | sed 's/?\s*/\n/g' | awk '{print $2}'`
  for j in $FIND0; do
    tmp_username=`echo $j | grep -Po '".*?"'`
    username=`echo ${tmp_username%\"} | cut -c 2-`
    if [ -z "${username}" ]; then
     tom_no_null_username="FALSE"
     break
    fi
  done
 fi
else
 tom_no_null_username="NOCHECK"
 nocheck_reason_item49=$tom_users_reason
fi

##################################01-检查是否有重复的Tomcat账号################################################
if [ $tom_users_check != "NOCHECK" ]; then 
 tom_users_CONFIG_DOCS=`cat ${tom_users_CONFIG} | sed '/<!--/{:a;/-->/!{N;ba}};/<!--/d'`
 FIND=`echo ${tom_users_CONFIG_DOCS} | tr ["\n"] [" "] | grep -Po '<user\s*username=".*?"\s*password=".*?"\s*roles=".*?"\s*/>'`
 if [ "${FIND}" ]; then
  web_admin_tomcat="FALSE"
 else
   web_admin_tomcat="TRUE"
 fi

 if [ "${web_admin_tomcat}" = "TRUE" ]; then
  FIND0=`echo $FIND | sed 's/?\s*/\n/g' | awk '{print $2}' | grep -Po '".*?"' | sort | uniq -c | sort -n | awk '{print $1"="$2;}'`
  for j in $FIND0;do
   username_repeat=`echo $j|awk -F= '{print $1}'`
   if [ $username_repeat -gt 1 ]; then
    tom_username_unique="FALSE"
   fi
  done
 fi
else
 tom_username_unique="NOCHECK"
 nocheck_reason_item50=$tom_users_reason
fi

##################################4.3.2 口令###############################################################
##################################01-检查Tomcat管理口令最小长度###############################################
if [ $tom_users_check != "NOCHECK" ]; then 
 tom_users_CONFIG_DOCS=`cat ${tom_users_CONFIG} | sed '/<!--/{:a;/-->/!{N;ba}};/<!--/d'`
 FIND=`echo ${tom_users_CONFIG_DOCS} | tr ["\n"] [" "] | grep -Po '<user\s*username=".*?"\s*password=".*?"\s*roles=".*?"\s*/>'`
 if [ "${FIND}" ]; then
  web_admin_tomcat="FALSE"
 else
   web_admin_tomcat="TRUE"
 fi

 if [ "${web_admin_tomcat}" = "TRUE" ]; then
  FIND0=`echo $FIND | sed 's/?\s*/\n/g' | awk '{print $3}'`
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
else
 tom_password_long_enough="NOCHECK"
 nocheck_reason_item51=$tom_users_reason
fi

##################################01-检查Tomcat管理口令组成类型###############################################
if [ $tom_users_check != "NOCHECK" ]; then 
 tom_users_CONFIG_DOCS=`cat ${tom_users_CONFIG} | sed '/<!--/{:a;/-->/!{N;ba}};/<!--/d'`
 FIND=`echo ${tom_users_CONFIG_DOCS} | tr ["\n"] [" "] | grep -Po '<user\s*username=".*?"\s*password=".*?"\s*roles=".*?"\s*/>'`
 if [ "${FIND}" ]; then
  web_admin_tomcat="FALSE"
 else
   web_admin_tomcat="TRUE"
 fi

 if [ "${web_admin_tomcat}" = "TRUE" ]; then 
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
else
 tom_password_complex_enough="NOCHECK"
 nocheck_reason_item52=$tom_users_reason
fi

##################################4.3.4 日志###############################################################
##################################01-检查Tomcat是否配置用户登录日志###############################################
if [ $tom_server_check != "NOCHECK" ]; then 
 tom_server_CONFIG_DOCS=`cat ${tom_server_CONFIG} | sed '/<!--/{:a;/-->/!{N;ba}};/<!--/d'`
 FIND=`echo ${tom_server_CONFIG_DOCS} | tr ["\n"] [" "] | grep -Po '<Valve\s*className=\s*"org.apache.catalina.valves.AccessLogValve"\s*directory.*?pattern=\s*"%h\s*%l\s*%u\s*%t\s*&quot;%r&quot;\s*%s\s*%b".*?/>'`
 if [ "${FIND}" ]; then
  tom_log_config="FALSE"
 else
  tom_log_config="TRUE"
 fi
else
 tom_log_config="NOCHECK"
 nocheck_reason_item53=$tom_server_reason
fi

##################################4.3.5 其他###############################################################
##################################01-检查Tomcat是否配置账号定时自动退出###############################################
if [ $tom_server_check != "NOCHECK" ]; then 
 tom_server_CONFIG_DOCS=`cat ${tom_server_CONFIG} | sed '/<!--/{:a;/-->/!{N;ba}};/<!--/d'`
 FIND=`echo ${tom_server_CONFIG_DOCS} | tr ["\n"] [" "] | grep -Po '<Connector.*?connectionTimeout=".*?".*?/>'`
 if [ "${FIND}" ]; then
  tom_connection_timeout="FALSE"
 else
  tom_connection_timeout="TRUE"
 fi
else
 tom_connection_timeout="NOCHECK"
 nocheck_reason_item54=$tom_server_reason
fi

##################################02-检查是否配置Tomcat错误页面重定向###############################################
if [ $tom_web_check != "NOCHECK" ]; then  
 tom_web_CONFIG_DOCS=`cat ${tom_web_CONFIG} | sed '/<!--/{:a;/-->/!{N;ba}};/<!--/d'` 
 FIND=`echo ${tom_web_CONFIG_DOCS} | tr ["\n"] [" "] | grep -Po '<error-page>.*?</error-page>'`
 if [ "${FIND}" ]; then
  tom_error_page="TRUE"
 else
  tom_error_page="FALSE"
 fi
else
 tom_error_page="NOCHECK"
 nocheck_reason_item55=$tom_web_reason
fi

##################################03-检查是否禁止Tomcat列表显示文件###############################################
if [ $tom_web_check != "NOCHECK" ]; then  
 tom_web_CONFIG_DOCS=`cat ${tom_web_CONFIG} | sed '/<!--/{:a;/-->/!{N;ba}};/<!--/d'` 
 FIND=`echo ${tom_web_CONFIG_DOCS} | tr ["\n"] [" "] | grep -Po '<init-param>\s*<param-name>listings</param-name>\s*<param-value>false</param-value>\s*</init-param>'`
 if [ "${FIND}" ]; then
  forbid_list_tomcat_file="FALSE"
 else
  forbid_list_tomcat_file="TRUE"
 fi
else
 forbid_list_tomcat_file="NOCHECK"
 nocheck_reason_item56=$tom_web_reason
fi

#############################输出json格式体检报告##########################################################
dict_sdavalue=("检查是否有重复的操作系统账号 不应存在相同的操作系统账号 OS-Linux-账号 5 1"
               "检查是否删除或锁定与设备运行、维护等工作无关的账号 所有无关账号都被删除或锁定 OS-Linux-账号 5 1" 
               "检查是否使用PAM认证模块禁止wheel组之外的用户su为root 使用PAM认证模块禁止wheel组之外的用户su为root OS-Linux-账号 5 1"
               "检查/etc/passwd文件权限 -rw-r--r--.,-r--r--r--. OS-Linux-授权 5 1"
               "检查/etc/shadow文件权限 -r--------.,----------. OS-Linux-授权 5 1"
               "检查/etc/group文件权限 -rw-r--r--.,-r--r--r--. OS-Linux-授权 5 1"
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
            "$password_min_length 最小长度:$password_min_length_config 最小长度:$password_min_length_config 无法查看/etc/login.defs和PAM文件"
            "$letter_classification 组成类别数:$letter_classification_config 组成类别数:$letter_classification_config 无法查看PAM文件"
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
            "$weblogic_send_server_header_enabled 已正确配置 未正确配置 $nocheck_reason_item45"
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