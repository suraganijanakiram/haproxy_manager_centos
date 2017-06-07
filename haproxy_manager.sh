#!/bin/bash
#used to install HAPoxy in centos and redhat systems
#email or comment suggestions and feedback to suraganijanakiram@gmail.com
clear
checkRoot() {
   if [ $(id -u) -ne 0 ]; then
     echo "Script must be run as root. Try 'sudo ./HAProxy_install.sh'\n"
     exit 1
   fi
}
echo -e "\n\n\t \e[1;32m Make sure you have repo for installing packages \e[0m \n"
check_conf()
{
if [ -f "/etc/haproxy/haproxy.cfg" ];
then
        true
else
        echo -e "\n\t \e[1;31m Install the package first. haproxy.cfg conf file does not exists! \e[0m \n"
        exit 1
fi
}
####################################################################
serverdetails()
{
echo -n -e "\nEnter the server hostname: "
read host
echo -n -e "\nEnter the server ipaddress: "
read ip
echo -n -e "\nEnter the server port on which service is listerning: "
read port
echo -e "\tserver $host $ip:$port cookie $host check" >> /etc/haproxy/haproxy.cfg
}
backupserverdetails()
{
echo -n -e "\nEnter the server hostname: "
read host
echo -n -e "\nEnter the server ipaddress: "
read ip
echo -n -e "\nEnter the server port on which service is listerning: "
read port
echo -e "\tserver $host $ip:$port check backup" >> /etc/haproxy/haproxy.cfg
}
backupserver_a()
{
while :
do
echo -n -e "\n\tDo you want to add another backup server :[\e[1;32mYes\e[0m/\e[1;31mNo\e[0m] "
read oo
case $oo in
        [yY]|[yY][eE][sS])
                backupserverdetails
        ;;
        [nN]|[nN][oO])
                break
        ;;
        *)
                echo -e "\n\t \e[1;31m Bad argument! \e[0m "
        ;;
esac
done
}
backupserver()
{
while :
do
echo -n -e "\n\tDo you want to add backup server :[\e[1;32mYes\e[0m/\e[1;31mNo\e[0m] "
read oo
case $oo in
        [yY]|[yY][eE][sS])
                backupserverdetails
                backupserver_a
                break
        ;;
        [nN]|[nN][oO])
                break
        ;;
        *)
                echo -e "\n\t \e[1;31m Bad argument! \e[0m "
        ;;
esac
done
}
addserver_a()
{
while :
do
echo -n -e "\n\tDo you want to add another server :[\e[1;32mYes\e[0m/\e[1;31mNo\e[0m] "
read oo
case $oo in
        [yY]|[yY][eE][sS])
                serverdetails
        ;;
        [nN]|[nN][oO])
                break
        ;;
        *)
                echo -e "\n\t \e[1;31m Bad argument! \e[0m "
        ;;
esac
done
}
addserver()
{
while :
do
echo -n -e "\n\tDo you want to add server : [\e[1;32mYes\e[0m/\e[1;31mNo\e[0m] "
read ooo
case $ooo in
        [yY]|[yY][eE][sS])
                serverdetails
                addserver_a
                backupserver
                break
        ;;
        [nN]|[nN][oO])
                break
        ;;
        *)
                echo -e "\n \e[1;31m Bad argument! \e[0m "
        ;;
esac
done
}
#####################################################################################################################
haproxy_install()
{
while :
do
echo -n -e "\n\tDo you want HTTPS:[\e[1;32mYes\e[0m/\e[1;31mNo\e[0m] "
read f
case $f in
        [yY]|[yY][eE][sS])
                echo -n -e "\nInstalling HAProxy "
                echo -n -e "\nPlease enter the required values for gererating certificate: "
        cd /etc/haproxy/
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout haproxy.key -out haproxy.crt
        cat haproxy.crt haproxy.key > haproxy.pem

        sed -i '/frontend LB/s/^#//g' /etc/haproxy/haproxy.cfg
        sed -i '/bind /s/^#//g' /etc/haproxy/haproxy.cfg
        sed -i '/reqadd X-Forwarded-Proto:/s/^#//g' /etc/haproxy/haproxy.cfg
        sed -i '/default_backend LB/s/^#//g' /etc/haproxy/haproxy.cfg
        sed -i '/redirect scheme https if/s/^#//g' /etc/haproxy/haproxy.cfg

        break
        ;;
        [nN]|[nN][oO])
                echo -n -e "\nInstalling only HAProxy. Recomended to use HTTPS with it"
                break
        ;;
        *)
                echo -e "\n\t \e[1;31m Bad argument! \e[0m "
        ;;
esac
done
}
install()
{
if [ -f "/etc/haproxy/haproxy.cfg" ];
then
        echo -e "\n\t\e[1;32mAlready installed\e[0m"
else
        yum clean all > /dev/null
        yum install haproxy openssl-devel mod_ssl -y > /dev/null
        check_conf

        sed -i '/$ModLoad imudp/s/^#//g' /etc/rsyslog.conf
        sed -i '/$UDPServerRun 514/s/^#//g' /etc/rsyslog.conf
        echo -e "local2.*\t/var/log/haproxy.log" >> /etc/rsyslog.d/haproxy.conf
        mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy_orinigal.txt
        echo -ne "\e[1;32m  Enter the ipaddres of HAProxy server : \e[0m"
        read ipaddress
        echo -ne "\e[1;32m  Enter username for web stats portal  : \e[0m"
        read username
        echo -ne "\e[1;32m  Enter password for web stats portal  : \e[0m"
        read -s password

        echo -e "global" >> /etc/haproxy/haproxy.cfg
        echo -e "\tlog\t127.0.0.1 local2" >> /etc/haproxy/haproxy.cfg
        echo -e "\tchroot\t/var/lib/haproxy" >> /etc/haproxy/haproxy.cfg
        echo -e "\tpidfile\t/var/run/haproxy.pid" >> /etc/haproxy/haproxy.cfg
        echo -e "\tmaxconn\t50000" >> /etc/haproxy/haproxy.cfg
        echo -e "\tuser\thaproxy" >> /etc/haproxy/haproxy.cfg
        echo -e "\tgroup\thaproxy" >> /etc/haproxy/haproxy.cfg
        echo -e "\tdaemon" >> /etc/haproxy/haproxy.cfg
        echo -e "\ttune.ssl.default-dh-param 2048" >> /etc/haproxy/haproxy.cfg
        echo -e "\tstats socket\t/var/lib/haproxy/stats" >> /etc/haproxy/haproxy.cfg
        echo -e "\n\n" >> /etc/haproxy/haproxy.cfg
        echo -e "defaults" >> /etc/haproxy/haproxy.cfg
        echo -e "\tmode\t\thttp" >> /etc/haproxy/haproxy.cfg
        echo -e "\tlog\t\tglobal" >> /etc/haproxy/haproxy.cfg
        echo -e "\toption\t\thttplog" >> /etc/haproxy/haproxy.cfg
        echo -e "\toption\t\tdontlognull" >> /etc/haproxy/haproxy.cfg
        echo -e "\toption http-server-close" >> /etc/haproxy/haproxy.cfg
        echo -e "\toption forwardfor\t\texcept 127.0.0.0/8" >> /etc/haproxy/haproxy.cfg
        echo -e "\toption\t\tredispatch" >> /etc/haproxy/haproxy.cfg
        echo -e "\tretries\t\t3" >> /etc/haproxy/haproxy.cfg
        echo -e "\ttimeout http-request\t\t20" >> /etc/haproxy/haproxy.cfg
        echo -e "\ttimeout queue\t\t86400" >> /etc/haproxy/haproxy.cfg
        echo -e "\ttimeout connect\t\t86400" >> /etc/haproxy/haproxy.cfg
        echo -e "\ttimeout client\t\t86400" >> /etc/haproxy/haproxy.cfg
        echo -e "\ttimeout server\t\t86400" >> /etc/haproxy/haproxy.cfg
        echo -e "\ttimeout http-keep-alive\t\t30" >> /etc/haproxy/haproxy.cfg
        echo -e "\ttimeout check\t\t20" >> /etc/haproxy/haproxy.cfg
        echo -e "\tmaxconn\t\t50000" >> /etc/haproxy/haproxy.cfg
        echo -e "\n\n" >> /etc/haproxy/haproxy.cfg
        echo -e "frontend LB" >> /etc/haproxy/haproxy.cfg
        echo -e "\tbind $ipaddress:80" >> /etc/haproxy/haproxy.cfg
        echo -e "\treqadd X-Forwarded-Proto:\ http" >> /etc/haproxy/haproxy.cfg
        echo -e "\tdefault_backend LB" >> /etc/haproxy/haproxy.cfg
        echo -e "\n" >> /etc/haproxy/haproxy.cfg
        echo -e "#frontend LBS" >> /etc/haproxy/haproxy.cfg
        echo -e "#\tbind $ipaddress:443 ssl crt /etc/haproxy/haproxy.pem" >> /etc/haproxy/haproxy.cfg
        echo -e "#\treqadd X-Forwarded-Proto:\ https" >> /etc/haproxy/haproxy.cfg
        echo -e "#\tdefault_backend LB" >> /etc/haproxy/haproxy.cfg
        echo -e "\n" >> /etc/haproxy/haproxy.cfg
        echo -e "\tbackend LB $ipaddress:80" >> /etc/haproxy/haproxy.cfg
        echo -e "#\tredirect scheme https if !{ ssl_fc }" >> /etc/haproxy/haproxy.cfg
        echo -e "\tmode http" >> /etc/haproxy/haproxy.cfg
        echo -e "\tstats enable" >> /etc/haproxy/haproxy.cfg
        echo -e "\tstats hide-version" >> /etc/haproxy/haproxy.cfg
        echo -e "\tstats uri /stats" >> /etc/haproxy/haproxy.cfg
        echo -e "\tstats realm Haproxy\ Statistics" >> /etc/haproxy/haproxy.cfg
        echo -e "\tstats auth $username:$password" >> /etc/haproxy/haproxy.cfg
        echo -e "\tbalance roundrobin" >> /etc/haproxy/haproxy.cfg
        echo -e "\toption httpchk" >> /etc/haproxy/haproxy.cfg
        echo -e "\toption  httpclose" >> /etc/haproxy/haproxy.cfg
        echo -e "\toption forwardfor" >> /etc/haproxy/haproxy.cfg
        echo -e "\tcookie LB insert" >> /etc/haproxy/haproxy.cfg

        haproxy_install
        addserver
        service rsyslog restart
        chkconfig rsyslog on
        systemctl enable rsyslog
        service haproxy restart
        service httpd stop
        chkconfig httpd off
        systemctl disable httpd
        chkconfig haproxy on
        systemctl enable haproxy
echo -e "\n\n\t \e[1;32m Installation of packages and configuration completed \e[0m \n"
fi
}
####################################### MAIN ########################################################################
while :
do
checkRoot
echo -e "\n \e[1;31m NOTE:- This script will stop your http service if running. haproxy should be configured in a seperate server. \e[0m \n"
echo -e "\n \e[1;32m choose any one option for HAProxy:- \e[0m \n\n  1\e[1;32m : \e[0mTo install package and configure \n\n  2\e[1;32m : \e[0mTo configure https if not configured \n\n  3\e[1;32m : \e[0mTo add another server \n\n  4\e[1;32m : \e[0mTo add backup server's \n\n  Q\e[1;32m : \e[0mExit"
read -p "enter the option number : " OPT
case $OPT in
  1)
        install
        ;;
  2)
        check_conf
        haproxy_install
        ;;
  3)
        check_conf
        addserver_a
        service haproxy restart
        ;;
  4)
        check_conf
        backupserver
        service haproxy restart
        ;;
  q|Q)
        echo -e "\n\t \e[1;31m Bye! \e[0m \n"
        exit 0
        ;;
  *)
        clear
        echo -e "\n \e[1;31m Bad argument! \e[0m \n"
        ;;
esac
done
