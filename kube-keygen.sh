#!/bin/bash

# Generates an rsa private key (for cryptographically signing things).
# Writes to <out_file_path> (use docker volume or docker export to retrieve files).
# Params:
#   key_file_path - file path to write key to (e.g. private.key)

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

key_file_path="${1:-}"
[ -z "${key_file_path}" ] && echo "No output key file path supplied (param 1)" && exit 1

openssl genrsa -out "${key_file_path}" 2048
