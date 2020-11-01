#!/bin/bash

# create base hadoop cluster docker image
docker build -f docker/base/Dockerfile -t rcebrian/hadoop-cluster-base:latest docker/base

# create primary node hadoop cluster docker image
docker build -f docker/primary/Dockerfile -t rcebrian/hadoop-cluster-primary:latest docker/primary


# the default node number is 3
N=${1:-3}

docker network create --driver=bridge hadoop &> /dev/null

# start hadoop replica container
i=1
while [ $i -lt $N ]
do
	docker run -itd \
	                --net=hadoop \
	                --name hadoop-replica-$i \
	                --hostname hadoop-replica-$i \
	                rcebrian/hadoop-cluster-base
	i=$(( $i + 1 ))
done 



# start hadoop primary container
docker run -itd \
                --net=hadoop \
                -p 50070:50070 \
                -p 8088:8088 \
                --name hadoop-primary \
                --hostname hadoop-primary \
				-v $PWD/data:/data \
                rcebrian/hadoop-cluster-primary



