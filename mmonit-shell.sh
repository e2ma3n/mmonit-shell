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

[ -f /tmp/error_1 ] && rm -f /tmp/error_1 &> /dev/null
[ -f /tmp/error_2 ] && rm -f /tmp/error_2 &> /dev/null

for (( j=0 ;; j++ )); do
	reset
	echo '[+] --------------------------------------------------------- [-]'
	echo -e "[+] Programming & idea by \e[1mE2MA3N [Iman Homayouni]\e[0m"
	echo -e "[+] Monitoring monit service manager on all servers"
	echo -e "[+] License : GPL v3.0\n"
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
					[ "$status" != "Running" ] && status=`echo -e "\e[101mNot running\e[0m"`
					echo -e "[+] $service $status"
					echo -e "[+] $ip - $service $status" | perl -pe 's/\e([^\[\]]|\[.*?[a-zA-Z]|\].*?\a)//g' | col -b >> /tmp/error_1
				fi
			done
		else
			echo "[-] maybe $ip is down" | tee -a /tmp/error_1
		fi
		echo
	done
	if [ "$j" != "0" ] ; then
		changes=`diff /tmp/error_2 /tmp/error_1 | grep '>' | cut -d " " -f 3,4,5,6,7,8`
		if [ ! -z "$changes" ] ; then
			for (( i=1 ; i <= `echo "$changes" | wc -l` ; i++ )) ; do
				zenity --timeout=1 --notification --text "mmonit-shell : `echo "$changes" | head -n $i | tail -n 1`" &> /dev/null
			done
		fi
	fi
	cp /tmp/error_1 /tmp/error_2
	rm -f /tmp/error_1 &> /dev/null
	echo "[+] refresh page after $delay second"
	echo '[+] --------------------------------------------------------- [-]'
	sleep $delay
done
