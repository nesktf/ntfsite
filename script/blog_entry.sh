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
md_title="${1//\//\\\\}"

mkdir -p "${ENTRY_DIR}/${docname}"
echo "# ${1}" > "${ENTRY_DIR}/${docname}/${md_title}.md"
${EDITOR} "${ENTRY_DIR}/${docname}/${md_title}.md"
