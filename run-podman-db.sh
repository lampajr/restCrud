#!/bin/sh
cd postgres
podman build -t restcrud-db .
podman run -d --name pgdocker --rm --net=host restcrud-db

