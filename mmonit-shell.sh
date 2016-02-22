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

# check config file
[ ! -f /opt/mmonit-shell_v1/mmonit-shell.conf ] && echo '[-] Error: /opt/mmonit-shell_v1/mmonit-shell.sh not found' && exit 1

# delay time for refresh
delay=`cat /opt/mmonit-shell_v1/mmonit-shell.conf | head -n 9 | tail -n 1 | cut -d = -f 2`

for (( ;; )); do
	reset
	echo -e "[+] Monitoring monit service manager on all servers\n"
	n=`cat /opt/mmonit-shell_v1/mmonit-shell.conf | wc -l`
	n=`expr $n - 11`
	for (( i=1 ; i<= $n ; i++ )) ; do
		data=`cat /opt/mmonit-shell_v1/mmonit-shell.conf | tail -n $n | head -n $i | tail -n 1`
		user=`echo "$data" | cut -d " " -f 1`
		pass=`echo "$data" | cut -d " " -f 2`
		ip=`echo "$data" | cut -d " " -f 3`
		port=`echo "$data" | cut -d " " -f 4`
		echo -e "[+] Connecting to $ip"
		curl --silent -u $user:$pass http://$ip:$port > /tmp/html
		if [ "$?" = "0" ] ; then
			monit=`links -dump /tmp/html`
			m=`echo "$monit" | grep -n Process | cut -d : -f 1`
			k=`echo "$monit" | grep -n Copyright | cut -d : -f 1`
			m=`expr $k - $m - 2`

			for service in `echo "$monit" | grep -A $m Process | tail -n $m | cut -d " " -f 1` ; do
				status=`echo "$monit" | grep "$service" | tr -s " " | cut -d " " -f 2`
				if [ ! -z $status ] ; then
					[ "$status" != "Running" ] && status=`echo -e "\e[101mNot running\e[0m"` && A=1
					echo -en "[+] " ; echo -en "$service " ; echo -e "$status"	
				fi
			done
			if [ -z $B ] ; then
				[ "$A" = "1" ] && B="1" && zenity --timeout=1 --notification --text "Monit - Problem on $ip" &> /dev/null
			fi
		else
			echo "[-] maybe server is down"
		fi
		echo
	unset A
	done
	echo "[+] refresh page after $delay second"
	sleep $delay
done
