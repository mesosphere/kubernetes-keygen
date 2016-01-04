#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

bin="$(cd "$(dirname "${BASH_SOURCE}")" && pwd -P)"

function usage {
  cat <<-EOF
USAGE: $FUNCNAME <SUBCOMMAND> [OPTIONS]

SUBCOMMANDS

	help	print this help text
	cagen	invoke kube-cagen.sh to generate an SSL certificate authority
	certgen	invoke kube-certgen.sh to generate an SSL certificate
	keygen	invoke kube-keygen.sh to generate an RSA private key

OPTIONS (See subcommand script file)
EOF
}

[ $# == 0 ] && usage && exit 1

subcmd="$1"
shift

case "${subcmd}" in
  help)
    usage
    exit
    ;;
  cagen)
    exec "${bin}/kube-cagen.sh" "$@"
    ;;
  certgen)
    exec "${bin}/kube-certgen.sh" "$@"
    ;;
  keygen)
    exec "${bin}/kube-keygen.sh" "$@"
    ;;
  *)
    echo "ERROR: unknown subcommand \"${subcmd}\""
    usage
    exit 1
    ;;
esac
