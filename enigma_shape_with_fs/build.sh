#!/bin/bash

# This script builds the docker image with tag sssilva/eshape:1.0
# To set the proxy use this format: [http://user:pass@proxy_server.com:port/]
docker build -t sssilvar/eshape_fs:1.0 \
	--build-arg proxy=$1\
	$(pwd)