#!/bin/sh

set -x # print command been ran
set -e # fail if any command fails


MONGO_PRIVATE_PORT="27017"

env;
ps auxwww;

printf "\n\t mongod:: start in the background \n\n";
mongod \
    --port="${MONGO_PRIVATE_PORT}" \
    --dbpath=/data/db \
    --bind_ip_all \
    --replSet="${MONGO_REPLICA_SET}" \
    --quiet > /tmp/mongo.log.json 2>&1 &

while ! nc -z localhost "${MONGO_PRIVATE_PORT}"; do
  printf "\n\t sleep waiting for port ${MONGO_PRIVATE_PORT} \n"
  sleep 1; # wait & retry
done

ps auxwww;

printf "\n\t mongod: set master \n\n";
mongo --port "${MONGO_PRIVATE_PORT}" --eval '
    rs.initiate(
    {
        _id: _getEnv("MONGO_REPLICA_SET"),
        version: 1,
        members: [
        { _id: 0, host : _getEnv("KUBERNETES_PUBLIC_IP") + ":" + _getEnv("MONGO_PUBLIC_PORT") }
        ]
    });
    sleep(3000);
    rs.status();';

printf "\n\t mongod: add user \n\n";
mongo --port "${MONGO_PRIVATE_PORT}" --eval '
    db.getSiblingDB("admin").createUser({
    user: _getEnv("MONGO_INITDB_ROOT_USERNAME"), 
    pwd: _getEnv("MONGO_INITDB_ROOT_PASSWORD"), 
    roles: [{ role: "userAdminAnyDatabase", db: "admin" }]
    });';

printf "\n\t mongod: shutdown \n\n";
mongod --shutdown;
sleep 1;
ps auxwww;

printf "\n\t mongod: restart with authentication \n\n";
mongod \
    --auth \
    --port="${MONGO_PRIVATE_PORT}" \
    --dbpath=/data/db \
    --bind_ip_all \
    --replSet="${MONGO_REPLICA_SET}" \
    --verbose=v
