#!/bin/bash

if [[ ! -e /config/deluge ]]; then
	mkdir -p /config/deluge
	chown -R ${PUID}:${PGID} /config/deluge
else
	chown -R ${PUID}:${PGID} /config/deluge
fi

## Check for missing group
/bin/egrep  -i "^${PGID}:" /etc/passwd
if [ $? -eq 0 ]; then
   echo "Group $PGID exists"
else
   echo "Adding $PGID group"
	 groupadd -g $PGID deluge
fi

## Check for missing userid
/bin/egrep  -i "^${PUID}:" /etc/passwd
if [ $? -eq 0 ]; then
   echo "User $PUID exists in /etc/passwd"
else
   echo "Adding $PUID user"
	 useradd -c "deluge user" -g $PGID -u $PUID deluge
fi

# set umask
export UMASK=$(echo "${UMASK}" | sed -e 's~^[ \t]*~~;s~[ \t]*$~~')

if [[ ! -z "${UMASK}" ]]; then
  echo "[info] UMASK defined as '${UMASK}'" | ts '%Y-%m-%d %H:%M:%.S'
else
  echo "[warn] UMASK not defined (via -e UMASK), defaulting to '002'" | ts '%Y-%m-%d %H:%M:%.S'
  export UMASK="002"
fi


# Set deluge WebUI and Incoming ports
if [ ! -z "${WEBUI_PORT}" ]; then
	webui_port_exist=$(cat /config/deluge/config/deluge.conf | grep -m 1 'WebUI\\Port='${WEBUI_PORT})
	if [[ -z "${webui_port_exist}" ]]; then
		webui_exist=$(cat /config/deluge/config/deluge.conf | grep -m 1 'WebUI\\Port')
		if [[ ! -z "${webui_exist}" ]]; then
			# Get line number of WebUI Port
			LINE_NUM=$(grep -Fn -m 1 'WebUI\Port' /config/deluge/config/deluge.conf | cut -d: -f 1)
			sed -i "${LINE_NUM}s@.*@WebUI\\Port=${WEBUI_PORT}@" /config/deluge/config/deluge.conf
		else
			echo "WebUI\Port=${WEBUI_PORT}" >> /config/deluge/config/deluge.conf
		fi
	fi
fi

if [ ! -z "${INCOMING_PORT}" ]; then
	incoming_port_exist=$(cat /config/deluge/config/deluge.conf | grep -m 1 'Connection\\PortRangeMin='${INCOMING_PORT})
	if [[ -z "${incoming_port_exist}" ]]; then
		incoming_exist=$(cat /config/deluge/config/deluge.conf | grep -m 1 'Connection\\PortRangeMin')
		if [[ ! -z "${incoming_exist}" ]]; then
			# Get line number of Incoming
			LINE_NUM=$(grep -Fn -m 1 'Connection\PortRangeMin' /config/deluge/config/deluge.conf | cut -d: -f 1)
			sed -i "${LINE_NUM}s@.*@Connection\\PortRangeMin=${INCOMING_PORT}@" /config/deluge/config/deluge.conf
		else
			echo "Connection\PortRangeMin=${INCOMING_PORT}" >> /config/deluge/config/deluge.conf
		fi
	fi
fi

echo "[info] Starting deluge daemon..." | ts '%Y-%m-%d %H:%M:%.S'
/bin/bash /etc/deluge/deluge.init start &
echo "[info] Starting deluge web..." | ts '%Y-%m-%d %H:%M:%.S'
/bin/bash /etc/deluge/deluge.init startweb &
chmod -R 755 /config/deluge

sleep 5s
qbpid=$(pgrep -o -x deluged)
qbwebpid=$(pgrep -o -x deluge-web)
echo "[info] deluge PID: $qbpid" | ts '%Y-%m-%d %H:%M:%.S'
echo "[info] deluge web PID: $qbwebpid" | ts '%Y-%m-%d %H:%M:%.S'

if [ -e /proc/$qbpid ]; then
	if [[ -e /config/deluge/logs/deluge-daemon.log ]]; then
		chmod 775 /config/deluge/logs/deluge-daemon.log
	fi
	if [[ -e /config/deluge/logs/deluge-web-daemon.log ]]; then
		chmod 775 /config/deluge/logs/deluge-web-daemon.log
	fi
	sleep infinity
else
	echo "deluge failed to start!"
fi
