# restCrud

## Start DB (Ideally this would be on a different machine, but for first request, it probably doesn't matter much).
```
./run-podman-db.sh
```
Note: You will need to pull postgres from dockerhub, or find an alternative.

## Update DB in src/main/resources/application.properties. 
Update the IP address on this line to where your DB is running.
```
quarkus.datasource.jdbc.url=jdbc:postgresql://10.16.112.12:5432/rest-crud
```

## Building Semeru Images
First, insert the security token into the .env file. (You can ask me for it).
```
./build.semeru.sh
```
This will build restcrud quarkus images with semeru and CRAC for 1, 2, and 4 cpus.

Note: You may need to change to a newer JDK build (line 93) or newer Tomcat build (line 132) in Dockerfile.quarkus.semeru.base. 

Note: The heap is set to 128m by default (see startQuarkus.sh to change).

Note: The executor threads are set to 8 by default (see startQuarkus.sh to change).

## Building Native Image
```
./build.native.sh
```
Note: The heap is set to 128m by default (see Dockerfile.quarkus.native to change).

Note: The executor threads are set to 8 by default (see Dockerfile.quarkus.native to change).


## Test First Request and Footprint at First Request
```
mkdir logs
./testFirstRequest.sh [IMAGE] [NUMBER_OF_CPUS]
```

Example
```
./testFirstRequest.sh restcrud-native 1
```

Note: You may need to change to your time zone on line 34 of doFirstRequestTests.sh. (Currently EDT).

# Throughput Instructions.

## Start Server on SUT (System Under Test)

Example
```
podman run --privileged -d --net=host --memory=1g --cpuset-cpus 2 restcrud-native
```

## On another machine (the driver), configure and run jmeter.

### Download and unzip Apache JMeter. https://dlcdn.apache.org//jmeter/binaries/apache-jmeter-5.6.3.zip (/opt/apache-jmeter-5.6.3/ for this example)

### Edit the following /opt/apache-jmeter-5.6.3/bin/jmeter.properties
```
#---------------------------------------------------------------------------
# Summariser - Generate Summary Results - configuration (mainly applies to non-GUI mode)
#---------------------------------------------------------------------------
#
# Comment the following property to disable the default non-GUI summariser
# [or change the value to rename it]
# (applies to non-GUI mode only)
summariser.name=summary
#
# interval between summaries (in seconds) default 30 seconds
summariser.interval=5
#
# Write messages to log file
summariser.log=true
#
# Write messages to System.out
summariser.out=true
```

### Copy the scripts in jmeter-scripts to the driver.

### The getFootprint.sh script gets the footprint measurement after heavy load. This script needs to access (ssh) the System Under Test without needing a password. So you will need to allow that (or comment it out of the run_pingPerf.sh script).

### Run Jmeter
```
./run_restCrud.sh [JMETER_HOME] [SUT]
```
Example:
```
./run_restCrud.sh /opt/apache-jmeter-5.6.3 checkers06.rtp.raleigh.ibm.com
```

The throughput measurement is the summary number of the last 5:00 run. (17600.3 below)
```
summary = 3159447 in 00:05:00 = 17600.3/s Avg:     5 Min:     0 Max:    70 Err:     0 (0.00%)
```

