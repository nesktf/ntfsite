#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ENTRY_DIR="${SCRIPT_DIR}/../data/blog"

if [[ -z ${1} ]]; then
  ( >&2 echo "No entry name provided")
  exit 1
fi

slug=$(printf "%s" "${1// /-}" | tr '[:upper:]' '[:lower:]')
timestamp=$(date +'%s')
docname="${timestamp}-${slug//\/}"
entry_file="${ENTRY_DIR}/${docname}/index.md"

mkdir -p "${ENTRY_DIR}/${docname}"

cat <<EOM > "${entry_file}"
+++
[BLOG_ENTRY]
title = "${1}"
subtitle = ""
timestamp = ${timestamp}
slug = "${docname}"
tags = []
+++


EOM

if [[ ${2} == "-n" ]]; then
  touch "${entry_file}"
else
  ${EDITOR} "${entry_file}"
fi
