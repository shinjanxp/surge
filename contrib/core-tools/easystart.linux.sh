#!/bin/bash
# Use environment variables to set these values, else these defaults will be used.

NUM_SHARDS=${NUM_SHARDS:-2}
NUM_REPLICAS=${NUM_REPLICAS:-4}
NUM_CLIENTS=${NUM_CLIENTS:-200}
DEPLOY_PATH=tmpfs/

rm -rf ${DEPLOY_PATH}chainspacecore-*
printf "$(date) Deployed shards: $NUM_SHARDS , replicas: $NUM_REPLICAS\n" >> stats/deploy-log.txt
# NUM_REPLICAS=$(($NUM_REPLICAS-1))
# NUM_SHARDS=$(($NUM_SHARDS-1))

# For each shard create config directories inside chainspacecore/ChainSpaceConfig and set the port 
> chainspacecore/ChainSpaceConfig/shardConfig.txt # empty the shard config file
rm -r chainspacecore/ChainSpaceConfig/shards/config*
# Modify the system.config file used by bft
sed -i "s/system.servers.num.*/system.servers.num = ${NUM_REPLICAS}/" chainspacecore/ChainSpaceConfig/shards/base_config/system.config

for SHARD_ID in $(seq 0 $(($NUM_SHARDS-1))) 
do
    cp -r chainspacecore/ChainSpaceConfig/shards/base_config chainspacecore/ChainSpaceConfig/shards/config$SHARD_ID
    printf "$SHARD_ID ChainSpaceConfig/shards/config$SHARD_ID\n" >> chainspacecore/ChainSpaceConfig/shardConfig.txt
    for REPLICA_ID in $(seq 0 $(($NUM_REPLICAS-1))) # Create host configs for each replica i.e. set the port
    do
        PORT=$((10000 + $SHARD_ID*1000 + 2*$REPLICA_ID))
        printf "$REPLICA_ID 127.0.0.1 $PORT\n" >> chainspacecore/ChainSpaceConfig/shards/config$SHARD_ID/hosts.config
    done
done
# Config done

for SHARD_ID in $(seq 0 $(($NUM_SHARDS-1))) # For each shard that we want to create. Every number here acts as the shard id
do
    for REPLICA_ID in $(seq 0 $(($NUM_REPLICAS-1))) # For each replica that we want to create within a shard. Every number here acts as the replica id
    do
        SCREEN_NAME="s"$SHARD_ID"n"$REPLICA_ID
        cp -r chainspacecore ${DEPLOY_PATH}chainspacecore-$SHARD_ID-$REPLICA_ID
        cd ${DEPLOY_PATH}chainspacecore-$SHARD_ID-$REPLICA_ID
        printf "shardConfigFile ChainSpaceConfig/shardConfig.txt\nthisShard $SHARD_ID\nthisReplica $REPLICA_ID" > ChainSpaceConfig/config.txt
        screen -dmSL $SCREEN_NAME java -cp lib/bft-smart-1.2.1-UCL.jar:target/chainspace-1.0-SNAPSHOT-jar-with-dependencies.jar uk.ac.ucl.cs.sec.chainspace.bft.TreeMapServer ChainSpaceConfig/config.txt
        cd ../../
        sleep 1
    done
    cd chainspacecore 
    SCREEN_NAME="s"$SHARD_ID"-clientService"
    screen -dmSL $SCREEN_NAME ./runclientservice.sh $SHARD_ID $DEPLOY_PATH
    cd ../
    sleep 1
done
