#!/bin/sh

# prerequisite: Kong has been started this way:
# docker-compose build
# docker-compose up
#
# For CORS tests (KONG-48), use:
#   CORS_ORIGINS="https://folio.example.com https://.*\\.example.com" docker-compose up --build
#   ./test-cors.sh
#
# See test-cors.sh for the full set of scenarios from the KONG-48 acceptance criteria.

for a in `seq 100`
do
  wget --no-verbose -O - localhost:8000 && break
  sleep 1
done  

assert () {
  if echo "$1" | grep -E "^$2" > /dev/null
  then
    echo "OK   found: $2"
  else
    echo "FAIL not found: $2"
    exit 1
  fi
}

assertNot () {
  if echo "$1" | grep -E "^$2"
  then
    echo "FAIL found: $2"
    exit 1
  else
    echo "OK   not found: $2"
  fi
}

OUT=$( wget --no-verbose -O - --header 'Foo: bar' --header 'Priority: u=4, i' --header 'Cookie: folioAccessToken=abc.def.ghi' --header 'Accept: text/plain' localhost:8000 )
echo "$OUT"
assert "$OUT" 'Accept: text/plain'
assert "$OUT" 'X-Okapi-Token: abc.def.ghi'
assertNot "$OUT" 'Cookie:'
assertNot "$OUT" 'Priority:'

