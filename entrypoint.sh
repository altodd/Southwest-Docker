#!/bin/sh
set -e

if [ "$1" != "/bin/sh" ]; then
	sudo service atd start
	sudo service cron start
	cd /headers/southwest-headers/
	env/bin/python southwest-headers.py /headers/southwest_headers.json
	autoluv "$@"
	while [ $(atq | wc -l) -gt 0 ]
	do
		sleep 60
	done
else
	exec "$@"
fi
