# Docker Zero Downtime Deploys

## Strategy

1. Proxy an nginx server group for a docker service
2. Scale up a new container while the old one is still running
3. Add both containers to the server group
4. Scale down the old container
5. Remove the old container from the server group

## Example

```sh
docker compose up -d

# Browser to port 8080
# Check "Auto Refresh"

./roll.sh
./roll.sh
...
```

## Notes

In an older versions of Docker Compose scaling down would leave
the new container running, but corrupt the DNS. I upgraded from
Docker 23.0.1 (Compose v2.16.0) to 27.1.1 (v2.29.1) and the
issue is no longer reproducible.

Inserting a sleep between removing the old container and scaling
down the service, then making a request in that window causes the
request to hang for a long time before recovering. Initial attempts
to set low nginx timeouts for the upstream and proxy did not seem
to correct the behavior. In practice this window seems impossible
to hit, but I would like to understand and fix it if possible.

## References

- https://www.tines.com/blog/simple-zero-downtime-deploys-with-nginx-and-docker-compose/
- https://medium.com/@aedemirsen/load-balancing-with-docker-compose-and-nginx-b9077696f624

