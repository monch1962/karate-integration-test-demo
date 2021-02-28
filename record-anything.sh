#!/bin/bash
# Set up 2 Hoverfly instances: one to be a stub that sends a dummy response
# to any incoming request, and the other running in capture mode
# to be a recording proxy for requests to the 1st stub
# We can then point tests at the 1st stub, using the 2nd stub as a proxy,
# and export the proxied request/response pairs from the 2nd stub. This
# gives us a record of all requests, with dummy responses

# First Hoverfly instance
docker run --name stub1 --rm -d -p 8888:8888 -p 8500:8500 spectolabs/hoverfly:latest -webserver
# Set this stub into webserver mode
#curl http://localhost:8888/api/v2/hoverfly/mode --upload-file tests/integration/stubs/webserver-mode.json
# Import a 'match-anything' stub into this instance
curl http://localhost:8888/api/v2/simulation --upload-file tests/integration/stubs/match-anything.stub.json
# Check that the match-anything config was loaded
echo "This is the config of stub1"
curl http://localhost:8888/api/v2/simulation
echo
curl http://localhost:8888/api/v2/hoverfly
echo
# Test instance 1
echo "Request sent to stub1"
curl http://localhost:8500/foo/bar
echo

# Second Hoverfly instance
docker run --name stub2 --rm -d -p 18888:8888 -p 18500:8500 spectolabs/hoverfly:latest
# Set 2nd Hoverfly instance into capture mode
curl http://localhost:18888/api/v2/hoverfly/mode --upload-file tests/integration/stubs/capture-mode.json
# Check that capture mode is enabled
echo "This is the config of stub2"
curl http://localhost:18888/api/v2/hoverfly/mode
echo
curl http://localhost:18888/api/v2/hoverfly
echo

# Send request to 1st instance, via 2nd instance acting as proxy
echo "Sending request to stub1 via stub2"
curl --proxy http://localhost:18500 http://localhost:8888/foo/bar
curl --proxy http://localhost:18500 http://jsonplaceholder.typicode.com/posts/1
echo

echo "Journal from stub1"
curl http://localhost:8888/api/v2/journal > stub1.json
cat stub1.json
echo
echo "Journal from stub2"
curl http://localhost:18888/api/v2/journal > stub2.json
cat stub2.json
echo

#echo "Export config from stub1"
#curl http://localhost:8888/api/records
#echo "Export config from stub2"
#curl http://localhost:18888/api/records
#echo

docker kill stub1
docker kill stub2
