#!/bin/bash

docker-compose down && \
docker rmi ip_nesmeyanova_ansible && \
docker images 
