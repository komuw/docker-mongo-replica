ARG MONGO_VERSION

FROM mongo:$MONGO_VERSION

LABEL repo="github.com/komuw/docker-mongo-replica"

# docker build -t alas .
# docker \
#     run \
#     -it \
#     --entrypoint \
#     /bin/bash \
#     -e MONGO_REPLICA_SET=myReplicaSet \
#     -e KUBERNETES_PUBLIC_IP=localhost \
#     -e MONGO_PUBLIC_PORT=27017 \
#     -e MONGO_INITDB_ROOT_USERNAME=someUser \
#     -e MONGO_INITDB_ROOT_PASSWORD=somePasswd \
#     -p 27017:27017/tcp \
#     alas:latest
#
# mongo "mongodb://someUser:somePasswd@localhost:27017/?authSource=admin&replicaSet=myReplicaSet"

RUN echo "using mongo version ${MONGO_VERSION}";apt -y update;apt -y install netcat

WORKDIR /usr/src/app

COPY entrypoint.sh /usr/src/app/entrypoint.sh
RUN chmod 755 /usr/src/app/entrypoint.sh

EXPOSE 27017

CMD ["/usr/src/app/entrypoint.sh"]
