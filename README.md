# docker-mongo-replica

Docker image with mongo replica.

Run:
```
make build
```

# Usage

```sh
make build

docker \
  run \
  -it \
  -e MONGO_REPLICA_SET=myReplicaSet \
  -e KUBERNETES_PUBLIC_IP=localhost \
  -e MONGO_PUBLIC_PORT=27017 \
  -e MONGO_INITDB_ROOT_USERNAME=someUser \
  -e MONGO_INITDB_ROOT_PASSWORD=somePasswd \
  -p 27017:27017/tcp \
  komuw/docker-mongo-replica:4.4.3-87c664e

mongo \
  "mongodb://someUser:somePasswd@localhost:27017/?authSource=admin&replicaSet=myReplicaSet"
```
