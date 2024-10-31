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
