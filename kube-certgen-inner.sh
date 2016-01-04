#!/bin/bash

# Creates an apiserver key and certificate with the provided IPs & default domain names.
# Uses the current dir for scratch work.
#TODO: abstract out "apiserver" name to post-processing. The alt-names are the only thing k8s specific.

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

bin="$(cd "$(dirname "${BASH_SOURCE}")" && pwd -P)"

in_dir="$1"
out_dir="$2"
apiserver_ip="$3"
service_ip="$4"
workspace="$(pwd)"
openssl_cnf="/etc/ssl/openssl.cnf"

if [ ! -f "${in_dir}/root-ca.key" ]; then
  echo "Signing key not found: ${in_dir}/root-ca.key"
  exit 1
fi
if [ ! -f "${in_dir}/root-ca.crt" ]; then
  echo "Root certificate not found: ${in_dir}/root-ca.key"
  exit 1
fi

mkdir -p "${out_dir}"

# TODO: extract config
subject="/C=GB/ST=London/L=London/O=example/OU=IT/CN=example.com"
cluster_domain="cluster.local"
service_name="kubernetes"
service_namespace="default"
subject_alt_name="IP:${apiserver_ip},IP:${service_ip},DNS:${service_name},DNS:${service_name}.${service_namespace},DNS:${service_name}.${service_namespace}.svc,DNS:${service_name}.${service_namespace}.svc.${cluster_domain}"

echo "Creating private key" 1>&2
"${bin}/kube-keygen.sh" "${workspace}/apiserver.key"

echo "Creating certificate sign request" 1>&2
openssl req -nodes -new -utf8 \
  -key "${workspace}/apiserver.key" \
  -out "${workspace}/apiserver.csr" \
  -reqexts SAN \
  -config <(cat "${openssl_cnf}"; echo -e "[SAN]\nsubjectAltName=${subject_alt_name}") \
  -subj "${subject}"

echo "Validating certificate sign request" 1>&2
openssl req -text -noout -in "${workspace}/apiserver.csr" | grep -q "${service_name}.${service_namespace}.svc.${cluster_domain}"

echo "Signing new certificate with root certificate authority key" 1>&2
mkdir -p "${workspace}/demoCA/newcerts"
touch "${workspace}/demoCA/index.txt"
echo 1000 > "${workspace}/demoCA/serial"
openssl ca -batch \
  -days 3650 \
  -in "${workspace}/apiserver.csr" \
  -cert "${in_dir}/root-ca.crt" \
  -keyfile "${in_dir}/root-ca.key" \
  -config <(sed 's/.*\(copy_extensions = copy\)/\1/' ${openssl_cnf})

echo "Validating signed certificate" 1>&2
openssl x509 -in "${workspace}/demoCA/newcerts/1000.pem" -text -noout | grep -q "${service_name}.${service_namespace}.svc.${cluster_domain}"

echo "Key: ${out_dir}/apiserver.key" 1>&2
cp "${workspace}/apiserver.key" "${out_dir}/apiserver.key"

echo "Cert: ${out_dir}/apiserver.crt" 1>&2
cp "${workspace}/demoCA/newcerts/1000.pem" "${out_dir}/apiserver.crt"
