#!/bin/bash

# Démarrage des services spark
/usr/local/spark/sbin/start-master.sh
/usr/local/spark/sbin/start-slave.sh spark://$HOSTNAME:7077 -m 2G -c 2


# Boucle sans fin
if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
