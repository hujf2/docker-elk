#!/bin/bash

set -e

docker build -t elk/kafka-manager .
echo "SUCCESS!"