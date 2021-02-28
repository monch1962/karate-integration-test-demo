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

echo "Journal from stub1"
curl http://localhost:8888/api/v2/journal
echo

docker kill stub1
