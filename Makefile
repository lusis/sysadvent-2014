CURDIR = `pwd`
CONTENTDIR = $(CURDIR)/var_nginx


all: image run

image:
	docker build --rm -t sysadvent-openresty .

run:
	docker run --rm --name sysadvent-openresty -p 3131:3131 -v $(CONTENTDIR):/var/nginx -i $(DOCKER_ENV) -t sysadvent-openresty

etcd:
	docker run -i --rm -p 8001:8001 -p 5001:5001 quay.io/coreos/etcd:v0.4.6 -addr $(PUBLIC_IP):5001 -name etcd-node1

etcd_populate:
	for i in `seq 10 30`;do curl -Ls -XPUT -d value=192.168.1.${i}:80${i} $(ETCD_URL)/v2/keys/lbs/backends/node${i}; sleep 2; done

.PHONY: image run etcd etcd_populate all
