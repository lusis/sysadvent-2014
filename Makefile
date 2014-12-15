CURDIR = `pwd`
CONTENTDIR = $(CURDIR)/var_nginx


all: image run

etcd: etcd_run etcd_populate etcd_attach

image:
	docker build --rm -t sysadvent-openresty .

run:
	docker run --rm --name sysadvent-openresty -p 3131:3131 -v $(CONTENTDIR):/var/nginx -i $(DOCKER_ENV) -t sysadvent-openresty

etcd_run:
	docker run --name etcd-node1 -d -p 8001:8001 -p 5001:5001 quay.io/coreos/etcd:v0.4.6 -addr $(PUBLIC_IP):5001 -name etcd-node1; sleep 5

etcd_populate:
	curl -Ls -XPUT -d value=127.0.0.1:3141 http://$(PUBLIC_IP):5001/v2/keys/lbs/backends/node1
	curl -Ls -XPUT -d value=127.0.0.1:3142 http://$(PUBLIC_IP):5001/v2/keys/lbs/backends/node2
	curl -Ls -XPUT -d value=127.0.0.1:3143 http://$(PUBLIC_IP):5001/v2/keys/lbs/backends/node3
	curl -Ls -XPUT -d value=127.0.0.1:3144 http://$(PUBLIC_IP):5001/v2/keys/lbs/backends/node4
	curl -Ls -XPUT -d value=127.0.0.1:3145 http://$(PUBLIC_IP):5001/v2/keys/lbs/backends/node5

etcd_attach:
	docker attach etcd-node1

etcd_destroy:
	docker stop etcd-node1
	docker rm etcd-node1

.PHONY: image run etcd etcd_run etcd_populate etcd_attach all
