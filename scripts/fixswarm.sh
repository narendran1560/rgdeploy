#!/bin/bash
version="0.1.2"
echo "Fixing swarm....(fixswarm.sh v$version)"

[ -z $RG_HOME ] && RG_HOME='/opt/deploy/sp2'
echo "RG_HOME=$RG_HOME"

# Remove the stack which is deployed if any
cd "$RG_HOME"
echo "Removing sp2 stack"
docker stack remove sp2
old_secrets=$(docker secret ls | grep -i sp2prod | awk '{print $1}' )
if [ ! -z "$old_secrets" ]; then
    echo "Found old secrets. Removing..."
    docker secret rm $old_secrets
fi
echo "Waiting 15 seconds"
sleep 15

# Remove this node from the swarm
echo 'Removing this node from the swarm'
docker swarm leave --force

# Remove the ingress network that is stuck
echo "Removing the stuck ingress network"
docker network ls | grep -e 'ingress.*overlay' | awk '{print $1}'

[ $? -gt 0 ] && echo "Could not remove ingress network. Exiting" && exit 0

echo "You can now re-deploy your stack using start_server.sh"
