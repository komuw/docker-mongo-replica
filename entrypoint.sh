#!/bin/sh

set -x # print command been ran
set -e # fail if any command fails

# Note, to disable non-auth in mongodb is kind of complicated.
# https://www.mongodb.com/features/mongodb-authentication
# https://dba.stackexchange.com/a/292134
#
# Note, the `_getEnv` function is internal and undocumented[3].
#
# openssl s_client -connect my-mongodb-pod.my-mongo-ns.svc:17011 -state -debug -showcerts
#
# 1. https://gist.github.com/thilinapiy/0c5abc2c0c28efe1bbe2165b0d8dc115
# 2. https://stackoverflow.com/a/54726708/2768067
# 3. https://stackoverflow.com/a/67037065/2768067

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
