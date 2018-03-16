docker build -t sssilvar/eshape_fs \
	--build-arg proxy=[http://user:pass@proxy_server.com:port/]\
	$(pwd)