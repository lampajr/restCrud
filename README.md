# restCrud

## The restCrud app is based off an applictaion Quarkus produced. This version varies from it slightly.
1. javax -> jakarta
2. greeting method added for instantOn first request testing
3. using the PathParam from the jakarta api instead of one provided by resteasy (hope this still works everywhere).

## Hibernate vs Eclipselink
There are multiple examples of server.xmls to use in src/main/liberty/config.
1. server.xml_hibernate_mp5.0. (hibernate is the JPA Provider, jakarta 9.x and mp5.0 features)
2. server.xml_hibernate_mp5.0. (hibernate is the JPA Provider, jakarta 10.0, and mp6.0 features)
3. server.xml_eclipelink. (eclipselink is the JPA Provider, and jakarta 9.0 features. Used for instantOn testing)

## Ways to get started.
Requires podman or docker. Using podman below, but docker should work also.

## Simple
Start the db

```./run-podman-db.sh```

Start app with maven.

```mvn clean package liberty:run```


## Using only Containers

Build App

```mvn clean package```

Start db and liberty containers

```podman-compose up --build```


## Fresh liberty install

Start the db

```./run-podman-db.sh```


Build App

```mvn clean package```

Create server

```cd ${WLP_HOME}/bin```

```server create```

Copy stuff
1. Copy src/main/liberty/config/serverxml to ${WLP_HOME}/usr/servers/defaultServer/
2. Copy src/main/liberty/config/jvm.options to ${WLP_HOME}/usr/servers/defaultServer/
3. Copy target/rest-crud.war to ${WLP_HOME}/usr/servers/defaultServer/apps
4. Copy resources/* to ${WLP_HOME}/usr/shared/resources

Start server

```server start```



# How to test (from Josh)
Start the server (pin to desired cpu-set if necessary)- from <liberty-install>/wlp

```taskset -c 2-3 ./bin/server start```

Note:you may also want to add --cpuset-cpus=<cpus> to the run-podman-db.sh script to pin the db cpus.)

Check the installation with curl - successful response looks like this

``` curl -s -w ''%{http_code}'' http://localhost:9080/crud/fruits ; echo "" ```

``` [{"id":2,"name":"Apple"},{"id":3,"name":"Banana"},{"id":1,"name":"Cherry"}]200 ```

Place the wrk binary from wrk/wrk on the load driver system

Create a tag for the URL:

 ```rcUrl=http://<liberty-IP>:9080/crud/fruits```

Run load with a command line like:

```thd=10; date; taskset -c 4-7 wrk -t$thd -c$thd -d30s $rcUrl```

```     Tue May  2 17:58:39 EDT 2023
        Running 30s test @ http://10.16.112.11:9080/crud/fruits
        10 threads and 10 connections
        Thread Stats   Avg      Stdev     Max   +/- Stdev
            Latency   806.42us    1.10ms  36.97ms   97.93%
            Req/Sec     1.45k   286.90     4.32k    85.65%
        432652 requests in 30.10s, 85.82MB read
        Requests/sec:  14373.78
        Transfer/sec:      2.85MB
```

## Running checkpoint restore with Quarkus
```
//start the db

//then create a networ so the source address can stay stable
 podman network create --subnet 192.168.200.0/24 myNetwork

//then do the 3-step process
podman build -f Dockerfile.quarkus --cap-add=ALL --secret id=criu_secrets,src=.env  -t start .
podman run --replace --name checkpointrun --privileged --net myNetwork --ip 192.168.200.10 -p 9090:9090 start
podman commit checkpointrun restorerun-crud
podman run --rm --name quarkus-restcrud --privileged --net myNetwork --ip 192.168.200.10 -p 9090:9090 restorerun-crud

//to end the run
podman kill quarkus-restcrud
```

