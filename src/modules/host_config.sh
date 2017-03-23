#################################################################################
#
# HOST Information detection
#
#################################################################################
#

    # Check operating system
    case `uname` in

      # Linux
        Linux)
          platform="Linux"
          OS_FULLNAME=""
          LINUX_VERSION=""
          HARDWARE=`LC_ALL=C uname -m`
          OS_KERNELVERSION_FULL=`LC_ALL=C uname -r`
          OS_KERNELVERSION=`echo ${OS_KERNELVERSION_FULL} | sed 's/-.*//'`
          IP_ADDR=`LC_ALL=C ifconfig|grep "inet addr:"|grep -v "127.0.0.1"|cut -d: -f2|awk '{print $1}'`
          MAC_ADDR=`LC_ALL=C ifconfig | grep -Po 'HWaddr.*' | awk '{print $2}'`
          HOST_NAME=`LC_ALL=C hostname -s 2> /dev/null`
          
          if [ -e "/etc/redhat-release" ]; then
                # CentOS
                FIND=`grep "CentOS" /etc/redhat-release`
                if [ ! "${FIND}" = "" ]; then
                    OS_FULLNAME=$FIND
                    LINUX_VERSION="CentOS"
                fi
                
                # Red Hat
                FIND=`grep "Red Hat" /etc/redhat-release`
                if [ ! "${FIND}" = "" ]; then
                    OS_FULLNAME=$FIND
                    LINUX_VERSION="Red Hat"
                fi
          fi

         if [ -e "/etc/lsb-release" ]; then
             FIND=`grep "^DISTRIB_ID=" /etc/lsb-release | cut -d '=' -f2 | sed 's/"//g'`
             if [ "${FIND}" = "Ubuntu" ]; then
               OS_FULLNAME=`grep "^DISTRIB_DESCRIPTION=" /etc/lsb-release | cut -d '=' -f2 | sed 's/"//g'`
               LINUX_VERSION="Ubuntu"
             fi
          fi
       ;;
       
        # other systems,not linux 
        *)
          platform="not linux systems"
          OS_FULLNAME="not linux systems"
          LINUX_VERSION="not linux systems"
          HARDWARE=""
          OS_KERNELVERSION="not linux systems"
          IP_ADDR=""
          HOST_NAME=""
        ;;

    esac   

   host_config="{\"HARDWARE\": \"$HARDWARE\", \"platform\": \"$platform\", \"LINUX_VERSION\": \"$LINUX_VERSION\", \"OS_FULLNAME\": \"$OS_FULLNAME\", \"OS_KERNELVERSION\": \"$OS_KERNELVERSION\", \"IP_ADDR\": \"$IP_ADDR\", \"MAC_ADDR\": \"$MAC_ADDR\", \"HOST_NAME\": \"$HOST_NAME\"}"

   echo $host_config
