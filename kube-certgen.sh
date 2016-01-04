#!/bin/bash

# Generates apiserver crt and key.
# Requires provided hostname to be resolvable (use docker link).
# Requires root certificate in <in_dir> (use docker volume).
# Writes to <out_dir> (use docker volume or docker export to retrieve files).
# Params:
#   hostname - host name of the Kubernetes API Server to resolve into an IP
#   in_dir   - dir to read root certificate from
#   out_dir  - (Optional) dir to write crt and key to  (default=<in_dir>)

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

bin="$(cd "$(dirname "${BASH_SOURCE}")" && pwd -P)"

in_dir="${1:-}" # must contain root-ca.crt & root-ca.key
[ -z "${in_dir}" ] && echo "No in_dir supplied (param 1)" && exit 1

out_dir="${2:-}"
[ -z "${out_dir}" ] && echo "No out_dir supplied (param 2)" && exit 1

hostname="${3:-}"
[ -z "${hostname}" ] && echo "No hostname supplied (param 3)" && exit 1

# Certificate generation depends on IP being resolvable from the provided hostname.
apiserver_ip="$(resolveip.sh ${hostname})"
service_ip="10.10.10.1" #TODO(karlkfi): extract config

intemp.sh -t "kube-certs" "'${bin}/kube-certgen-inner.sh' '${in_dir}' '${out_dir}' '${apiserver_ip}' '${service_ip}'"
