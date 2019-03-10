#!/bin/bash

CONF_FILENAME=/etc/pacmake.conf

LIB_PATH=/tmp/pkg/lib     #/var/lib/pkg
CACHE_PATH=/tmp/pkg/cache #/var/cache/pkg
TARGET_PATH=/tmp/pkg/root #/
SOURCE_PREFIX=/tmp/pkg/repo

# shellcheck source=/dev/null
source "${CONF_FILENAME}" 2>/dev/null

MAKE_CMDLINE_BASE="make -C ${LIB_PATH}/defs LIB_PATH=${LIB_PATH} CACHE_PATH=${CACHE_PATH} TARGET_PATH=${TARGET_PATH} SOURCE_PREFIX=${SOURCE_PREFIX}"

action=$1
shift 1

function do_action() {
    if [[ $# -eq 0 ]]; then
        if [[ ${action} != sync ]]; then
            echo 'error: no packages specified' >&2
            return 2
        fi

        ${MAKE_CMDLINE_BASE} sync
        return 0
    fi

    local targets
    for package_name; do
        targets="${targets} ${action}_${package_name}"
    done
    # shellcheck disable=SC2086
    ${MAKE_CMDLINE_BASE} ${targets}
}

function init() {
    mkdir -p "${LIB_PATH}/defs" "${LIB_PATH}/installed"
    rsync -az "${SOURCE_PREFIX}/lib/defs/Makefile" "${LIB_PATH}/defs"
}

function update() {
    rsync -az --include='*.mk' "${SOURCE_PREFIX}/lib/defs/" "${LIB_PATH}/defs"
}

function upgrade() {
    if [[ $# -gt 0 ]]; then
        echo 'error: partial upgrades are not supported' >&2
        return 3
    fi

    ${MAKE_CMDLINE_BASE} upgrade
}

case ${action} in
init)
    init || exit $?
    ;;

update)
    update || exit $?
    ;;

upgrade)
    upgrade || exit $?
    ;;

sync | sync_nodeps | install | uninstall | uninstall_cascade)
    do_action "$@" || exit $?
    ;;

*)
    echo 'error: invalid action specified' >&2
    exit 1
    ;;

esac
