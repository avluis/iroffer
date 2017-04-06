#!/bin/bash
set -e

init_data_dir() {
  echo "Initializing ${IROFFER_DATA_DIR}..."
	
  mkdir -p ${IROFFER_DATA_DIR}
  chmod -R 0750 ${IROFFER_DATA_DIR}
  chown -R ${IROFFER_USER}:${IROFFER_USER} ${IROFFER_DATA_DIR}

  echo "Done."
}

init_log_dir() {
  echo "Initializing ${IROFFER_LOG_DIR}..."
  mkdir -p ${IROFFER_LOG_DIR}
  chmod -R 0755 ${IROFFER_LOG_DIR}
  touch ${IROFFER_LOG_DIR}/${IROFFER_LOG_FILE}
  chown -R ${IROFFER_USER}:${IROFFER_USER} ${IROFFER_LOG_DIR}

  echo "Done."
}

# copy sample config
if [ "${1:0:1}" = '-s' ]; then
	ls -la
fi

# allow arguments to be passed to iroffer launch
if [ "${1:0:1}" = '-' ]; then
	set -- ./iroffer "$@"
fi

init_data_dir
init_log_dir

# default behavior
if [[ -z ${1} ]]; then
  exec -i -t -d ./iroffer
else
  exec "$@"
fi
