#!/usr/bin/env bash
check_footprint () {
    ssh skylake2 ps -ef|grep java|grep -v grep|awk '{print $2}' > pid
    pid="$(head -1 pid)"
    fp="$(ssh skylake2 ps -o rss= -p $pid)"
    echo checking footprint $fp
}

remove_class_cache () {
ssh skylake2 /bin/bash > /dev/null << EOF
    cd $was_home
    cp defaultServer/jvm.options.tp defaultServer/jvm.options
    #cp crudServer/jvm.options.tp crudServer/jvm.options
    export JAVA_HOME=$java_home
    ./stopDefaultServer.sh
    #./stopCrudServer.sh
    rm -rf .classCache
EOF
}

start_liberty () {
ssh skylake2 /bin/bash > /dev/null << EOF
    cd $was_home
    export JAVA_HOME=$java_home
    ./startDefaultServerShare.sh
    #./startCrudServerShare.sh
EOF
#ssh skylake2 "cd /opt/performanceinspector-standalone/Dpiperf/bin;. setrunenv;cd $was_home;export JAVA_HOME=$java_home;./startDefaultServerShare.sh"
}

dostartup_liberty () {
    remove_class_cache
    start_liberty
    sleep 5s
    #check_footprint
    #totalccstartfp="$(echo "$totalccstartfp $fp" | awk '{print $1+$2}')"
    #curl -s -o /dev/null -w "%{http_code}" $url > /dev/null
    #sleep 5s
    #check_footprint
    #totalccfirstreqfp="$(echo "$totalccfirstreqfp $fp" | awk '{print $1+$2}')"
    #numccfp=$((numccfp+1))
    #stop_liberty
    #sleep 1s
    #start_liberty
    #for run in {1..4}
    #do
    #   sleep 5s
    #   check_footprint
    #   totalstartfp="$(echo "$totalstartfp $fp" | awk '{print $1+$2}')"
    #   curl -s -o /dev/null -w "%{http_code}" $url > /dev/null
    #   sleep 5s
    #   check_footprint
    #   totalfirstreqfp="$(echo "$totalfirstreqfp $fp" | awk '{print $1+$2}')"
    #   numfp=$((numfp+1))
    #   stop_liberty
    #   sleep 1s
    #   start_liberty
    #done
}

dostartup_wildfly () {
ssh skylake2 /bin/bash > /dev/null << EOF
    cd /opt/wildfly-17.0.1.Final
    export JAVA_HOME=$java_home
    bin/jboss-cli.sh --connect command=:shutdown
    rm -rf .classCache
    ./startPingperf.sh
EOF
}

stop_liberty () {
  ssh skylake2 /bin/bash > /dev/null << EOF
  cd $was_home
  ./stopDefaultServer.sh
  #./stopCrudServer.sh
EOF
}

total=0
num=0
totalccstartfp=0
totalccfirstreqfp=0
numccfp=0
totalstartfp=0
totalfirstreqfp=0
numfp=0
totalendfp=0
numendfp=0
duration=60s
#liberty pingperf
url=http://192.168.90.176:9080/pingperf/ping/simple
#url=http://192.168.90.176:9080/crud/fruits
#was_home=/opt/202004201106/wlp/usr/servers/
#was_home=/opt/20200409-0300/wlp/usr/servers/
was_home=/opt/202020.0.0.5/wlp/usr/servers/
java_home=/opt/java/openj9/jdk8u252-b09/
#java_home=/opt/java/openj9/nightly/dynamicThreading/j2sdk-image/
appserver=liberty
#for t in {1..4}
for t in {1..3}
do
    #quarkus pingperf
    #url=http://192.168.90.176:8080/ping/simple
    #competitive pingperf
    #url=http://192.168.90.157:8080/pingperf/ping/simple
    #liberty crud
    #url=http://192.168.90.176:9080/crud/fruits
    #quarkus crud
    #url=http://192.168.90.176:8080/fruits
    
    dostartup_$appserver
    check_footprint

    for USERS in 40
    do
        for run in {1..2}
        do
            ./wrk --threads=$USERS --connections=$USERS -d$duration $url > runoutput
            tput="$(grep "Requests/sec" runoutput | awk '{print $2}')"
            echo Warmup run throughput $tput
        done

	for run in {1..3}
        do
            ./wrk --threads=$USERS --connections=$USERS -d$duration $url > runoutput;
            tput="$(grep "Requests/sec" runoutput | awk '{print $2}')"
            echo Run$run throughput $tput
            total="$(echo "$total $tput" | awk '{print $1+$2}')"
            num=$((num+1))
	done
    done
    endfp="$(ssh skylake2 ps -o rss= -p $pid)"
    echo endfp is $endfp
    totalendfp="$(echo "$totalendfp $endfp" | awk '{print $1+$2}')"
    numendfp=$((numendfp+1))
done
avg="$(echo "$total $num" | awk '{print $1/$2}')"
avgendfp="$(echo "$totalendfp $numendfp" | awk '{print $1/$2}')"
avgccstartfp="$(echo "$totalccstartfp $numccfp" | awk '{print $1/$2}')"
avgccfirstreqfp="$(echo "$totalccfirstreqfp $numccfp" | awk '{print $1/$2}')"
avgstartfp="$(echo "$totalstartfp $numfp" | awk '{print $1/$2}')"
avgfirstreqfp="$(echo "$totalfirstreqfp $numfp" | awk '{print $1/$2}')"
echo Initial footprint after classcache deletion $avgccstartfp, First Request footprint after classcache deletion $avgccfirstreqfp, Initial footprint $avgstartfp, First Request footprint $avgfirstreqfp, Final footprint $avgendfp
echo Average of last $num runs is $avg
stop_$appserver
