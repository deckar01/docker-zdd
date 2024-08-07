#!/usr/bin/env sh

SERVICE="example"
PROXY="proxy"
PORT="80"

# Start a second updated container
old_container_id=$(docker ps -f name=$SERVICE -q | tail -n1)
docker compose up -d --no-deps --scale $SERVICE=2 --no-recreate $SERVICE

# Wait for it to accept requests
new_container_id=$(docker ps -f name=$SERVICE -q | head -n1)
new_container_ip=$(docker inspect -f \
	'{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
	$new_container_id)
curl -o /dev/null --fail --retry-connrefused \
	--retry-delay 1 --retry-max-time 20 \
	http://$new_container_ip:$PORT/ || exit 1

# Clear the load balancer DNS cache
proxy_container_id=$(docker ps -f name=$PROXY -q | head -n1)
docker exec $proxy_container_id /usr/sbin/nginx -s reload

# Remove the outdated container
docker rm -f $old_container_id
docker compose up -d --no-deps --scale $SERVICE=1 --no-recreate $SERVICE

# Clear the load balancer DNS cache
docker exec $proxy_container_id /usr/sbin/nginx -s reload

