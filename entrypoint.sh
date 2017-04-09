#!/bin/bash

# allow arguments
if [ "${1:0:1}" = '-' ]; then
	set -- ./iroffer "$@"
fi

# skip setup
wantHelp=
for arg; do
	case "$arg" in
		-'?'|-h|-v|-c)
			wantHelp=1
			break
			;;
	esac
done

init_config() {
  # Config
  mkdir -p ${IROFFER_CONFIG_DIR}
  chmod -R 0755 ${IROFFER_CONFIG_DIR}
  chown -R ${IROFFER_USER}: ${IROFFER_CONFIG_DIR}

  # Data
  mkdir -p ${IROFFER_DATA_DIR}
  touch ${IROFFER_DATA_DIR}/packlist.txt
  chmod -R 0750 ${IROFFER_DATA_DIR}
  chown -R ${IROFFER_USER}: ${IROFFER_DATA_DIR}

  # Logs
  mkdir -p ${IROFFER_LOG_DIR}
  touch ${IROFFER_LOG_DIR}/mybot.log
  chmod -R 0755 ${IROFFER_LOG_DIR}
  chown -R ${IROFFER_USER}: ${IROFFER_LOG_DIR}
}

# allow the container to be started with `--user`
if [ "$1" = './iroffer' -a -z "$wantHelp" -a "$(id -u)" = '0' ]; then
  echo "Mode: Flag"
# prep
	init_config
	exec ./iroffer "$BASH_SOURCE" "$@"
fi

# default -- connects to irc.rizon.net
if [[ -z ${1} ]]; then
  echo "Mode: Default"
# prep
  init_config
  exec ./iroffer -u ${IROFFER_USER} ${IROFFER_CONFIG_DIR}/mybot.config
else
  echo "Mode: Other"
  exec "$@"
fi