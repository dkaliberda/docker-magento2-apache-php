#!/bin/bash

redis-cli -h clusterdata HSET fb_apache_containers `tail -n1 /etc/hosts`

exit 0
