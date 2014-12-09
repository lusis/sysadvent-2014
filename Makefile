CURDIR = `pwd`
CONTENTDIR = $(CURDIR)/var_nginx


all: image run

image:
	docker build --rm -t sysadvent-openresty .

run:
	docker run --rm --name sysadvent-openresty -p 3131:3131 -v $(CONTENTDIR):/var/nginx -i $(DOCKER_ENV) -t sysadvent-openresty

.PHONY: image run all
