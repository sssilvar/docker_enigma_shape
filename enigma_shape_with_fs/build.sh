#!/bin/bash

# This script builds the docker image with tag sssilva/eshape:1.0
docker build -t sssilvar/eshape_fs:1.0 \
	--build-arg proxy=[http://user:pass@proxy_server.com:port/]\
	$(pwd)