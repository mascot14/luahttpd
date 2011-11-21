#!/bin/sh

SERVER_HOST="localhost"
SERVER_PORT="1351"

if [ "$1" ]; then
	echo "test case $1"
	if [ -f  "$1".correct ]; then
		exec cat "$1" | nc "$SERVER_HOST" "$SERVER_PORT" | tee lastresult.log | sed -r 's/^Date: (Mon|Tue|Wed|Thu|Fri|Sat|Sun), [0-9][0-9] (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) 20[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9] GMT$/Date: \[rfc822 date\]/' | diff - "$1".correct

	else
		exec cat "$1" | nc "$SERVER_HOST" "$SERVER_PORT" | sed -r 's/^Date: (Mon|Tue|Wed|Thu|Fri|Sat|Sun), [0-9][0-9] (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) 20[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9] GMT$/Date: \[rfc822 date\]/' | tee "$1".correct | sed 's//^M/' # the first ^M is a real CR char, the second one is simply carrat+M
	fi

else
	rm -f run.log
	../onehttpd -l -v -p "$SERVER_PORT" ./docroot/ 2>run.log &
	ONEHTTPDPID="$!"
	sleep 1
	for f in *.tc; do
		if ! "$0" "$f"; then
			echo TEST CASE "$f" FAILED
			break
		fi
	done
	kill "$ONEHTTPDPID"

	sleep 1

	echo "server messages are in ./run.log"
fi
