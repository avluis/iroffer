#!/bin/bash
set -e

init_config() {
  # Config
  mkdir -p ${IROFFER_CONFIG_DIR}
  chmod -R 0755 ${IROFFER_CONFIG_DIR}
  cp -n /extras/sample.config ${IROFFER_CONFIG_DIR}/mybot.config
  chown -R ${IROFFER_USER}:${IROFFER_USER} ${IROFFER_CONFIG_DIR}

  # Data
  mkdir -p ${IROFFER_DATA_DIR}
  chmod -R 0750 ${IROFFER_DATA_DIR}
  chown -R ${IROFFER_USER}:${IROFFER_USER} ${IROFFER_DATA_DIR}

  # Logs
  mkdir -p ${IROFFER_LOG_DIR}
  chmod -R 0755 ${IROFFER_LOG_DIR}
  touch ${IROFFER_LOG_DIR}/${IROFFER_LOG_FILE}
  chown -R ${IROFFER_USER}:${IROFFER_USER} ${IROFFER_LOG_DIR}
}

# allow arguments to be passed to iroffer launch
if [ "${1:0:1}" = '-' ]; then
	set -- ./iroffer "$@"
fi

init_config

# default behavior
if [[ -z ${1} ]]; then
  exec ./iroffer -u ${IROFFER_USER} ${IROFFER_CONFIG_DIR}/mybot.config && \
  tail -F ${IROFFER_LOG_DIR}/${IROFFER_LOG_FILE}
else
  exec "$@"
fi