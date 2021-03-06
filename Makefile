IMAGE=micktwomey/postgresql
VERSION=9.3.4-1
TAG=$(IMAGE):$(VERSION)
TAG_LATEST=$(IMAGE):latest

build:
	docker build -t $(TAG) .
	docker tag $(TAG) $(TAG_LATEST)

shell:
	docker run --rm -i -t --entrypoint=/bin/bash -u root $(TAG) -i

run:
	docker run -i -t --name=postgresql $(TAG)

start:
	docker run -d --name=postgresql $(TAG)

tag:
	git tag $(VERSION)
