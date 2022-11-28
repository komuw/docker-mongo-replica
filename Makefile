
DOCKER_REGISTRY=komuw
PROJECT_NAME=docker-mongo-replica
LATEST_COMMIT=$(shell git log -n 1 --pretty=format:%h)
ALTREPO=$(DOCKER_REGISTRY)/$(PROJECT_NAME)
MONGO_VERSION="4.4.3"

build:
	docker ps -aq | xargs docker rm -f;docker volume ls -q | xargs docker volume rm -f | echo ''
	docker build -t "${ALTREPO}:v${MONGO_VERSION}-${LATEST_COMMIT}" .

push: build
	docker push --all-tags $(ALTREPO)
