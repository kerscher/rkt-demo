#!/bin/bash
set -eu

log_error(){
    if [ -S /dev/log ]; then
        logger \
            --tag "$(basename "$0")" \
            --stderr \
            --priority 'user.error' \
            "${1}"
    else
        echo "${1}"
    fi
}

if [ "${1}" != "oci" ] &&
   [ "${1}" != "docker" ]; then
    log_error "must call with either 'oci' or 'docker' as sole parameter"
    exit 1
fi

if [ -z "${2}" ]; then
    log_error "need to pass image in name:tag format as second parameter"
    exit 1
fi

shopt -s expand_aliases
alias b=buildah

script_path="$(dirname "$(realpath --no-symlinks "$0")")"
cd "${script_path}"

container=$(buildah from nginx)
b copy "${container}" "./files/it-works.txt" '/usr/share/nginx/html/it-works.txt'
b commit \
  --format "${1}" \
  --rm \
  "${container}" "${2}"
echo "${container}"
