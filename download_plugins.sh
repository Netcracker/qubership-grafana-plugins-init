#!/bin/bash

# Abort on the first failed download or unzip. Without it, a plugin version that
# does not exist leaves an empty download behind, and the build passes anyway.
set -eo pipefail

######################################################################################################################
#                                                      Constants                                                     #
######################################################################################################################

REGISTRY_URL="https://grafana.com/api/plugins"
TEMP_PATH="/tmp"
DOWNLOADS_PATH="${TEMP_PATH}/downloads"
DESTINATION_PATH="${TEMP_PATH}/plugins"
RELEASE_VERSION="old-plugins"
OLD_PLUGINS_RELEASE_URL="https://github.com/Netcracker/qubership-grafana-plugins-init/releases/download/${RELEASE_VERSION}"

######################################################################################################################
#                                                  Download plugins                                                  #
######################################################################################################################

mkdir -p "${DOWNLOADS_PATH}" "${DESTINATION_PATH}"

echo "Start to read file with plugins ..."
while IFS='' read -r line || [[ -n "${line}" ]]; do
    if [[ "${line}" =~ ^[[:space:]]*(#|$) ]]; then
        continue
    fi

    read -r -a array <<<"${line}"
    plugin_name="${array[0]}"
    version="${array[1]}"

    if [[ -z "${plugin_name}" || -z "${version}" ]]; then
        echo "Malformed line in plugins.list: ${line}" >&2
        echo "Each entry must be '<plugin_name> <version>'." >&2
        exit 1
    fi

    echo "Try to download plugin: ${plugin_name} - ${version}..."
    wget --no-check-certificate -P "${DOWNLOADS_PATH}/${plugin_name}" \
        -r -nd --quiet --no-parent \
        "${REGISTRY_URL}/${plugin_name}/versions/${version}/download"

    unzip "${DOWNLOADS_PATH}/${plugin_name}/download" -d "${DESTINATION_PATH}"
done <"plugins.list"
echo "Official plugins successfully downloaded"

######################################################################################################################
#                                  Download old AngularJS plugins from old_plugins.list                              #
######################################################################################################################

echo "Start to download old AngularJS plugins..."
while IFS='' read -r plugin || [[ -n "${plugin}" ]]; do
    if [[ "${plugin}" =~ ^[[:space:]]*(#|$) ]]; then
        continue
    fi

    echo "Downloading old plugin ${plugin} from GitHub Release..."
    wget -q -O "${DOWNLOADS_PATH}/${plugin}.zip" \
        "${OLD_PLUGINS_RELEASE_URL}/${plugin}.zip"
    unzip -q "${DOWNLOADS_PATH}/${plugin}.zip" -d "${DESTINATION_PATH}"
done <"old_plugins.list"

echo "Old AngularJS plugins successfully downloaded"

echo "Print downloaded plugins into directory:"
ls -lah "${DOWNLOADS_PATH}"

echo "Plugins download process successfully complete"

echo "List of plugins directories:"
ls -lah "${DESTINATION_PATH}"

echo "Build script successfully complete"
