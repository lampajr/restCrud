#!/usr/bin/env bash

#for USERS in 1 5 10 15 20 25 30 35 40
#for USERS in 20 30 40 50
#for USERS in 20
	for run in {1..5}
   do
		 ./wrk -t40 -c40 -d60s http://192.168.90.176:8080/ping/simple;
		 #./wrk -t40 -c40 -d60s http://192.168.90.176:9080/crud/fruits;
		 #./wrk -t40 -c40 -d60s http://192.168.90.176:8080/fruits;
		 #./wrk -t40 -c40 -d60s http://192.168.90.176:9080/pingperf/ping/simple;
		 #./wrk -t40 -c40 -d60s http://skylake3:9080/pingperf/ping/simple;
	done

