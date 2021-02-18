clear
echo "Starting 3 Cassandra, 3 Stargate and 1 Traefik container(s)"

# Startup Cassandra and Traefik
docker-compose up -d cassandra traefik

# Wait until Cassandra is ready
until docker logs docker-compose-stargate-traefik_cassandra_1 | grep -q "Startup complete";
do
    sleep 2
    echo "Waiting for Cassandra (1/3) to startup..."
done

# Scale Cassandra to 2 nodes
docker-compose up -d --scale cassandra=2 cassandra

# Wait until Cassandra is ready
until docker logs docker-compose-stargate-traefik_cassandra_2 | grep -q "Startup complete";
do
    sleep 2
    echo "Waiting for Cassandra (2/3) to startup..."
done

# Scale Cassandra to 3 nodes
docker-compose up -d --scale cassandra=3 cassandra

# Wait until Cassandra is ready
until docker logs docker-compose-stargate-traefik_cassandra_3 | grep -q "Startup complete";
do
    sleep 2
    echo "Waiting for Cassandra (3/3) to startup..."
done

# Startup Stargate
docker-compose up -d stargate

# Wait until Stargate is ready
until docker logs docker-compose-stargate-traefik_stargate_1 2>/dev/null | grep -q "Finished starting bundles";
do
    sleep 2
    echo "Waiting for Stargate (1/3) to startup..."
done

# Scale Stargate to 2 nodes
docker-compose up -d --scale stargate=2 stargate

# Wait until Stargate is ready
until docker logs docker-compose-stargate-traefik_stargate_2 2>/dev/null | grep -q "Finished starting bundles";
do
    sleep 2
    echo "Waiting for Stargate (2/3) to startup..."
done

# Scale Stargate to 3 nodes
docker-compose up -d --scale stargate=3 stargate

# Wait until Stargate is ready
until docker logs docker-compose-stargate-traefik_stargate_3 2>/dev/null | grep -q "Finished starting bundles";
do
    sleep 2
    echo "Waiting for Stargate (3/3) to startup..."
done

# Show container performance
docker stats -a