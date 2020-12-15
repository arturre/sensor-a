echo "----------Test the root endpoint: ----------"
curl -i localhost:8000
echo "\n\n----------Get healthcheck info: ----------"
curl -i localhost:8000/health
echo "\n\n----------Get metadata info: ----------"
curl -i localhost:8000/metadata