#!/bin/bash

######################################################################################################################
#                                                      Constants                                                     #
######################################################################################################################

REGISTRY_URL="https://grafana.com/api/plugins"
TEMP_PATH="/tmp"
DOWNLOADS_PATH="${TEMP_PATH}/downloads"
DESTINATION_PATH="${TEMP_PATH}/plugins"

######################################################################################################################
#                                                  Download plugins                                                  #
######################################################################################################################

mkdir -p ${DOWNLOADS_PATH} ${DESTINATION_PATH}

echo "Start to read file with plugins ..."
while IFS='' read -r line || [[ -n "${line}" ]]; do
  if [[ "${line}" != \#* ]]; then
    array=( ${line} )

    plugin_name=${array[0]}
    version=${array[1]}

    echo "Try to download plugin: ${plugin_name} - ${version}..."
    wget --no-check-certificate -P "${DOWNLOADS_PATH}/${plugin_name}" \
        -r -nd --quiet --no-parent \
        "${REGISTRY_URL}/${plugin_name}/versions/${version}/download" \

    unzip "${DOWNLOADS_PATH}/${plugin_name}/download" -d ${DESTINATION_PATH}
  fi
done < "plugins.list"
echo "Plugins successfully downloaded"

echo "Print downloaded plugins into directory:"
ls -lah "${DOWNLOADS_PATH}"

echo "Plugins download process successfully complete"

echo "Rename folder 'dist' of novatec-sdg plugin to old name 'novatec-sdg-panel'"
mv ${DESTINATION_PATH}/dist ${DESTINATION_PATH}/novatec-sdg-panel

echo "List of plugins directories:"
ls -lah ${DESTINATION_PATH}

echo "Build script successfully complete"
