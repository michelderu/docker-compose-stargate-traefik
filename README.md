# Scalable docker-compose with Cassandra and Stargate, loadbalanced by Traefik
This project aims to create a scalable (up and down) environment for Cassandra and Stargate.  
Cassandra is globally accepted as the most reliable and scalable database delibering single-digit-millisecond performance.  
Stargate is a developer friendly gateway to Cassandra that offers REST, Document and GraphQL APIs.

Storage (Cassandra) and Stargate (Compute) can be separately scaled up and down. Traefik is used to load balance any number Stargate instances.

## Traefik host name
Traefik will listen to the hostname `stargate.localhost` for loadbalancing Stargate requests. In order for this to work, you might need to extend your `/etc/hosts` file as follows:
```
##
# Host Database
#
# localhost is used to configure the loopback interface
# when the system is booting.  Do not change this entry.
##
127.0.0.1	localhost
127.0.0.1	stargate.localhost
```

## Scripted startup
There are two scripts provided to startup the cluster.
- `start-c1s1t1.sh` will start the cluster with 1 node of Cassandra, 1 node of Stargate and 1 node of Traefik
- `start-c3s2t1.sh` will start the cluster with 3 nodes of Cassandra, 2 nodes of Stargate and 1 node of Traefik

Cassandra is configured with a maximum heap size of 4 GB. Stargate with a heapsize of 2 GB but will mostly use 1 GB.

After startup `docker stats` will be started for insight in resource consumption.

## Manual startup
It is also possible to run the cluster using `docker-compose` in a manual way.

### Startup 1 Cassandra, 1 Stargate and 1 Traefik container
Start Cassandra ans Traefik:
```sh
docker-compose up -d cassandra traefik
```
Wait for Cassandra to startup, this can be checked by waiting for `"Startup complete"` to appear in the logs:
```sh
docker logs docker-compose-stargate-traefik_cassandra_1
```
Now startup Stargate:
```sh
docker-compose up -d stargate
```
Wait for Stargate to startup, this can be checked by waiting for `"Finished starting bundles"` to appear in the logs:
```sh
docker logs docker-compose-stargate-traefik_stargate_1
```

### Scale up 
Now that you have a cluster running with 1 Cassandra, 1 Stargate and 1 Traefik node, you can scale-up Storage (Cassandra) and Compute (Stargate) separately from each other.

It is best practise to scale up one-by-one, waiting for the container to start and settle.

#### Scale up Cassandra
In order to scale Cassandra, use:
```sh
docker-compose up -d --scale cassandra=<n> cassandra
```
Replace `<n>` with the amount of containers to run. Remember to scale one-by-one starting with 2 and check the log:
```sh
docker logs docker-compose-stargate-traefik_cassandra_<n>
```
Replace `<n>` with the current scale.

#### Scale up Stargate
In order to scale Stargate, use:
```sh
docker-compose up -d --scale stargate=<n> stargate
```
Replace `<n>` with the amount of containers to run. Remember to scale one-by-one starting with 2 and check the log:
```sh
docker logs docker-compose-stargate-traefik_stargate_<n>
```
Replace `<n>` with the current scale.

## Understanding the cluster
Cassandra nodes are responsible for storage. Stargate nodes are responsible for handling the compute for the API endpoints.  
This is also shown through the token ring cluster as follows:
- Cassandra nodes are shown through `nodetool status` as nodes running in the dc/rack. They should al be `UN` (Up and Normal)
- Stargate nodes connect themselves to the token ring also but have a specialization to not store data. They can be shown through `nodetool describecluster`. The new nodes compared to the previous command will be the stargate nodes.
- To double check, you can compare the IP adresses with the Stargate containers using `docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' docker-compose-stargate-traefik_stargate_<n>`

## Test performance using JMeter
Download JMeter from https://jmeter.apache.org/download_jmeter.cgi and unpack in the current directory.  
Run the test in CLI mode:
```sh
./apache-jmeter-5.4.1/bin/jmeter -n -t ingest.jmx -l ingest.csv -e -o ./results
```

## Run cqlsh
```sh
docker exec -it docker-compose-stargate-traefik_cassandra_1 cqlsh
```