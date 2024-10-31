#!/bin/sh
cd postgres
docker build -t restcrud-db .
docker run -d --name pgdocker --rm -p 5432:5432 restcrud-db

