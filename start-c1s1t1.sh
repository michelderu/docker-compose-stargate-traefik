clear
echo "Starting 1 Cassandra, 1 Stargate and 1 Traefik container(s)"

# Startup Cassandra and Traefik
docker-compose up -d cassandra traefik

# Wait until Cassandra is ready
until docker logs docker-compose-stargate-traefik_cassandra_1 | grep -q "Startup complete";
do
    sleep 2
    echo "Waiting for Cassandra (1/1) to startup..."
done

# Startup Stargate
docker-compose up -d stargate

# Wait until Stargate is ready
until docker logs docker-compose-stargate-traefik_stargate_1 2>/dev/null | grep -q "Finished starting bundles";
do
    sleep 2
    echo "Waiting for Stargate (1/1) to startup..."
done

# Show container performance
docker stats -a