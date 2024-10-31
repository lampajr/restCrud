#!/bin/bash

# Check if the directory "cr" exists
if [ -d "cr" ]; then
    exec dumb-init --rewrite 15:2 -- "./restore.sh"
else
    echo "start checkpoint run"
    for i in {1..500}; do ./pidplus.sh; done
    mkdir cr
    $JAVA_HOME/bin/java -Xmx128m -Dquarkus.thread-pool.max-threads=8 -Dquarkus.thread-pool.core-threads=8 -Dquarkus.http.host=0.0.0.0 -XX:CRaCCheckpointTo=cr -Dquarkus.http.port=9090 -Dopenj9.internal.criu.unprivilegedMode=true $JAVA_OPTS -jar target/quarkus-app/quarkus-run.jar 1>out 2>err </dev/null &
    sleep 10
    for i in {1..100}; do curl -s -w ''%{http_code}'' http://localhost:9090/fruits ; echo ""; done
    $JAVA_HOME/bin/jcmd target/quarkus-app/quarkus-run.jar JDK.checkpoint
    cat out
    cat err
    sleep 10
    echo "end checkpoint run"
fi

