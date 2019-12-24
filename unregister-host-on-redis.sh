#!/bin/bash

redis-cli -h clusterdata HDEL fb_apache_containers `tail -n1 /etc/hosts`

exit 0
