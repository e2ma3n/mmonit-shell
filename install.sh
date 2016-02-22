#! /bin/bash
# Programming and idea by : E2MA3N [Iman Homayouni]
# Github : https://github.com/e2ma3n
# Email : e2ma3n@Gmail.com
# Website : http://OSLearn.ir
# License : GPL v3.0
# mmonit-shell v1.0 [ Monitoring 'monit service manager' on all servers ]
# ---------------------------------------------------------------------- #

# check root privilege
[ "`whoami`" != "root" ] && echo '[-] Please use root user or sudo' && exit 1

# help function
function help_f {
	echo 'Usage: '
	echo '	sudo ./install.sh -i [install program]'
	echo '	sudo ./install.sh -c [check dependencies]'
}

# install program on system
function install_f {
	[ ! -d /opt/mmonit-shell_v1/ ] && mkdir -p /opt/mmonit-shell_v1/ && echo "[+] Directory created" || echo '[-] Error: /opt/mmonit-shell_v1/ exist'
	sleep 1
	[ ! -f /opt/mmonit-shell_v1/mmonit-shell_v1.sh ] && cp mmonit-shell.sh /opt/mmonit-shell_v1/ && chmod 700 /opt/mmonit-shell_v1/mmonit-shell.sh && echo '[+] mmonit-shell.sh copied' || echo '[-] Error: /opt/mmonit-shell_v1/mmonit-shell.sh exist'
	sleep 1
	[ -f /opt/mmonit-shell_v1/mmonit-shell.sh ] && ln -s /opt/mmonit-shell_v1/mmonit-shell.sh /usr/bin/mmonit-shell &> /dev/null && echo '[+] symbolic link created' || echo '[-] Error: /opt/mmonit-shell_v1/mmonit-shell.sh not found'
	sleep 1
	[ ! -f /opt/mmonit-shell_v1/mmonit-shell.conf ] && cp mmonit-shell.conf /opt/mmonit-shell_v1/ && chmod 400 /opt/mmonit-shell_v1/mmonit-shell.conf && echo '[+] mmonit-shell.conf copied' || echo '[-] Error: /opt/mmonit-shell/mmonit-shell.conf exist'
	sleep 1
	[ ! -f /opt/mmonit-shell_v1/README ] && cp README /opt/mmonit-shell_v1/ ; echo '[+] Please see README'
}

# check dependencies on system
function check_f {
	echo '[+] check dependencies on system:  '
	for program in watch whoami cat cp links expr curl
	do
		if [ ! -z `which $program 2> /dev/null` ] ; then
			echo "[+] $program found"
		else
			echo "[-] Error: $program not found"
		fi
	done
}

case $1 in
	-i) install_f ;;
	-c) check_f ;;
	*) help_f ;;
esac
