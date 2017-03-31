#!/bin/bash
set -e

init_data_dir() {
  echo "Initializing ${IROFFER_DATA_DIR}..."
	
  mkdir -p ${IROFFER_DATA_DIR}
  chmod -R 0750 ${IROFFER_DATA_DIR}
  chown -R ${IROFFER_USER}:${IROFFER_USER} ${IROFFER_DATA_DIR}
}

init_log_dir() {
  echo "Initializing ${IROFFER_LOG_DIR}..."
  mkdir -p ${IROFFER_LOG_DIR}
  chmod -R 0755 ${IROFFER_LOG_DIR}
  touch ${IROFFER_LOG_DIR}/${IROFFER_LOG_FILE}
  chown -R ${IROFFER_USER}:${IROFFER_USER} ${IROFFER_LOG_DIR}
}

# allow arguments to be passed to iroffer launch
if [[ ${1:0:1} = '-' ]]; then
  EXTRA_ARGS="$@"
  set -- ./iroffer
fi

init_data_dir
init_log_dir

# default behavior
if [[ -z ${1} ]]; then
  exec ./iroffer -b -u ${IROFFER_USER} ${IROFFER_CONFIG_DIR}/${IROFFER_CONFIG_FILE} && \
  tail -F ${IROFFER_LOG_DIR}/${IROFFER_LOG_FILE}
else
  exec "$@"
fi
