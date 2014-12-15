CURDIR = `pwd`
CONTENTDIR = $(CURDIR)/var_nginx


all: image run

image:
	docker build --rm -t sysadvent-openresty .

run:
	docker run --rm --name sysadvent-openresty -p 5001:5001 -p 8001:8001 -p 3131:3131 -v $(CONTENTDIR):/var/nginx -i --env ETCD_URL="http://127.0.0.1:5001" $(DOCKER_ENV) -t sysadvent-openresty

.PHONY: image run all
