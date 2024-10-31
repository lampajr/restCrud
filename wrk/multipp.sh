#!/bin/bash

dur=$1
if [[ -z $dur ]] ; then dur=30s ; fi ; echo "duration: $dur"
shift

USERS=$1
if [[ -z $USERS ]] ; then USERS=25 ; fi ; echo "users: $USERS"
shift

numa0="numactl --physcpubind 14-15"
numa1="numactl --physcpubind 16-17"
numa2="numactl --physcpubind 18-19"
numa3="numactl --physcpubind 21-22"
numa4="numactl --physcpubind 23-24"
numa5="numactl --physcpubind 25-26"

host=10.16.112.38
#host=localhost

url1="http://${host}:9080/pingperf/ping/simple"
url2="http://${host}:9080/pingperf/ping/simple"
url3="http://${host}:9080/pingperf/ping/simple"
url4="http://${host}:9080/pingperf/ping/simple"
url5="http://${host}:9080/pingperf/ping/simple"

#url1="http://${host}:9080/alpha/ping/simple"
#url2="http://${host}:9080/bravo/ping/simple"
#url3="http://${host}:9080/charlie/ping/simple"
#url4="http://${host}:9080/delta/ping/simple"
#url5="http://${host}:9080/echo/ping/simple"

url0="http://${host}:9080/pingperf0/ping/simple"
url1="http://${host}:9081/pingperf1/ping/simple"
url2="http://${host}:9082/pingperf2/ping/simple"
url3="http://${host}:9083/pingperf3/ping/simple"
url4="http://${host}:9084/pingperf4/ping/simple"
#url5="http://${host}:9085/pingperf5/ping/simple"

#url1="http://${host}:9080/pingperf/ping/simple"
#url2="http://${host}:9081/pingperf/ping/simple"
#url3="http://${host}:9082/pingperf/ping/simple"
#url4="http://${host}:9083/pingperf/ping/simple"
#url5="http://${host}:9084/pingperf/ping/simple"

PIDS=""
( $numa0 ./wrk --threads=$USERS --connections=$USERS -d$dur $url0 | grep "Requests/sec" ) &  PIDS="$PIDS $!"
( $numa1 ./wrk --threads=$USERS --connections=$USERS -d$dur $url1 | grep "Requests/sec" ) &  PIDS="$PIDS $!"
( $numa2 ./wrk --threads=$USERS --connections=$USERS -d$dur $url2 | grep "Requests/sec" ) &  PIDS="$PIDS $!"
( $numa3 ./wrk --threads=$USERS --connections=$USERS -d$dur $url3 | grep "Requests/sec" ) &  PIDS="$PIDS $!"
( $numa4 ./wrk --threads=$USERS --connections=$USERS -d$dur $url4 | grep "Requests/sec" ) &  PIDS="$PIDS $!"
#( $numa5 ./wrk --threads=$USERS --connections=$USERS -d$dur $url5 | grep "Requests/sec" ) &  PIDS="$PIDS $!"

wait $PIDS



