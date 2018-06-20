#!/bin/bash

echo "Starting SSH daemon..."
service ssh start

echo "Starting Hadoop services..."
hdfs namenode -format
start-dfs.sh
start-yarn.sh

tail -qF /usr/local/hadoop/logs/*.log
