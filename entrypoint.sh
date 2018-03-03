#!/bin/bash
set -e

# allow arguments
if [ "${1:0:1}" = '-' ]; then
  echo "Arg:""$@"
  set -- ./iroffer "$@"
fi

init_config() {
  # Config
  if [ ! -d "${IROFFER_CONFIG_DIR}" ]; then
    mkdir -p ${IROFFER_CONFIG_DIR}
    if [ ! -e "${IROFFER_CONFIG_DIR}/${IROFFER_CONFIG_FILE_NAME}" ]; then
      cp /extras/sample.customized.config "${IROFFER_CONFIG_DIR}/${IROFFER_CONFIG_FILE_NAME}"
      echo "Copied fresh sample configuration to ${IROFFER_CONFIG_DIR}/${IROFFER_CONFIG_FILE_NAME}. Exiting."
      exit
    fi
    chmod -R 0755 ${IROFFER_CONFIG_DIR}
    chown -R ${IROFFER_USER}: ${IROFFER_CONFIG_DIR}
  fi

  # Data
  if [ ! -d "${IROFFER_DATA_DIR}" ]; then
    mkdir -p ${IROFFER_DATA_DIR}
    chmod -R 0750 ${IROFFER_DATA_DIR}
    chown -R ${IROFFER_USER}: ${IROFFER_DATA_DIR}
  fi

  # Logs
  if [ ! -d "${IROFFER_LOG_DIR}" ]; then
    mkdir -p ${IROFFER_LOG_DIR}
    chmod -R 0755 ${IROFFER_LOG_DIR}
    chown -R ${IROFFER_USER}: ${IROFFER_LOG_DIR}
  fi
}

# Startup
if [[ -z ${1} ]]; then
# default
# prep
  init_config
  exec ./iroffer -kns -u ${IROFFER_USER} -w $USER/ ${IROFFER_CONFIG_DIR}/${IROFFER_CONFIG_FILE_NAME}
else
# -?|-h|-v|-c
  exec "$@"
fi