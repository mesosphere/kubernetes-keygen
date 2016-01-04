# Kubernetes Key Generator

Scripts for generating RSA keys and SSL certificates/authorities for use by Kubernetes cluster deployments.


## Usage

The scripts are packages as a docker container image and hosted on DockerHub.

To use the image, invoke docker run with the desired subcommand and arguments.


### cagen

Generate an SSL certificate authority (public certificate, signing request, private key):

```
docker run -it --rm -v "$(pwd):/out" mesosphere/kubernetes-keygen cagen /out
```

Output:

- ./root-ca.crt
- ./root-ca.csr
- ./root-ca.key


### certgen

Generate an SSL certificate (public certificate, private key):

```
docker run -it --rm -v "$(pwd):/in" -v "$(pwd):/out" mesosphere/kubernetes-keygen certgen /in /out apiserver
```

Note: "apiserver" above is the hostname to resolve to an IP. The cert will be created using that IP as the primary IP and 10.10.10.1 as the secondary IP (kubernetes apiserver service). This assumes that the "apiserver" host or domain name is resolvable from inside the docker network or using the host's dns resolver.

Output:

- ./apiserver.crt
- ./apiserver.key


### keygen

Generate a private RSA key:

```
docker run -it --rm -v "$(pwd):/out" mesosphere/kubernetes-keygen keygen /out/private.key
```

Output:

- ./private.key


## TODO

1. Make the certgen subcommand more configurable
1. Use flag arguments instead of ordered arguments


## License

Copyright 2015 Mesosphere, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.