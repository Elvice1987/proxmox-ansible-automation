#!/usr/bin/env bash

COUNT=3

for i in $(seq 1 $COUNT); do
  echo "Starte Deployment $i..."
  ./auto-deploy.sh
  sleep 10
done
