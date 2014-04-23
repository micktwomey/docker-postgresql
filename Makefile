TAG=micktwomey/postgresql

build:
	docker build -t $(TAG) .

shell:
	docker run --rm --link postgresql:pg -i -t --entrypoint=/bin/bash $(TAG) -i

run:
	-docker rm postgresql
	docker run -i -t --name=postgresql $(TAG)
