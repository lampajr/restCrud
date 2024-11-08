JMETER_HOME=${1}
SUT=${2}

sleep 5
THREADS=100

${JMETER_HOME}/bin/jmeter.sh -n -t simple.jmx -JHOST=${SUT} -JPORT=9090 -JTHREAD=100 -JDURATION=30 -JURL=/fruits
sleep 5
${JMETER_HOME}/bin/jmeter.sh -n -t simple.jmx -JHOST=${SUT} -JPORT=9090 -JTHREAD=${THREADS} -JDURATION=60 -JURL=/fruits
sleep 5
${JMETER_HOME}/bin/jmeter.sh -n -t simple.jmx -JHOST=${SUT} -JPORT=9090 -JTHREAD=${THREADS} -JDURATION=180 -JURL=/fruits
./getFootprint.sh ${SUT}
sleep 5
${JMETER_HOME}/bin/jmeter.sh -n -t simple.jmx -JHOST=${SUT} -JPORT=9090 -JTHREAD=${THREADS} -JDURATION=300 -JURL=/fruits

