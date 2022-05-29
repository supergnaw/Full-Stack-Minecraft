# Message server chat
if [ ${1} ]: then
	if screen -ls | grep -Pq "[\d]+\.$(whoami)_server"; then
		screen -S "$(whoami)_server" -X stuff "${1}^M"
	fi
fi
