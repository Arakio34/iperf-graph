#!/bin/bash
# add_penalty.sh 
# author :JMP dec 2014


if [ "$#" -ne 2 ]
   then
      echo "Usage: $0 delay|loss|duplicate nombre"
      exit 1
fi

TYPE=$1
VALEUR=$2

if [ $TYPE == "delay" ]
then
   DELAY="$2ms"
   echo -ne "ajout d'un delais de $DELAY \n" 
   tc qdisc replace dev veth-client root netem delay  $DELAY
   ip netns exec latency-network  tc qdisc replace dev veth-server root netem delay $DELAY
elif [ $TYPE == "loss" ]
then
   LOSS="$2%"
   echo -ne "ajout d'une perte de $LOSS \n" 
   tc qdisc replace dev veth-client root netem loss  $LOSS
   ip netns exec latency-network  tc qdisc replace dev veth-server root netem loss $LOSS
elif [ $TYPE == "duplicate" ]
then
   DUP="$2%"
   echo -ne "ajout d'une duplication de $DUP \n" 
   tc qdisc replace dev veth-client root netem duplicate  $DUP
   ip netns exec latency-network  tc qdisc replace dev veth-server root netem duplicate $DUP
else echo -ne  "delay loss duplicate manquant\n"   
fi

SHOWTCC=$(tc -p -s -d  qdisc show)
SHOWTCS=$(ip netns exec latency-network  tc -p -s -d  qdisc show)
echo -ne "$SHOWTCC \n"
echo -ne "$SHOWTCS \n"

