#!/bin/bash

# Generates root certificate authority crt and key.
# Writes to <out_dir> (use docker volume or docker export to retrieve files).
# Params:
#   out_dir  - dir to write crt and key to

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

bin="$(cd "$(dirname "${BASH_SOURCE}")" && pwd -P)"

out_dir="${1:-}"
[ -z "${out_dir}" ] && echo "No out_dir supplied (param 1)" && exit 1


# TODO(karlkfi): extract config
subject="/C=GB/ST=London/L=London/O=example/OU=IT/CN=example.com"

echo "Creating private key" 1>&2
"${bin}/kube-keygen.sh" "${out_dir}/root-ca.key"

echo "Creating certificate sign request" 1>&2
openssl req -nodes -new -utf8 \
  -key "${out_dir}/root-ca.key" \
  -out "${out_dir}/root-ca.csr" \
  -subj "${subject}"

echo "Signing new certificate with private key" 1>&2
openssl x509 -req -days 3650 \
  -in "${out_dir}/root-ca.csr" \
  -out "${out_dir}/root-ca.crt" \
  -signkey "${out_dir}/root-ca.key"

echo "Key: ${out_dir}/root-ca.key" 1>&2
echo "Cert: ${out_dir}/root-ca.crt" 1>&2
