#! /bin/bash

exec ${geth_command} &

sleep 3
enode=$(geth --exec "admin.nodeInfo.enode" attach | sed "s/\[::\]/$(grep $(hostname) /etc/hosts | head -n1 | awk '{print $1}')/g")

if [ "${use_consul}" == "true" ] ; then
  echo "Bootstrap using consul"
  consul_up=0
  while [ $consul_up -ne 1 ]
  do
    curl -s -X PUT -d "${enode}" http://consul:8500/v1/kv/ethereum_node_$(hostname)
    if [ $? -eq 0 ] ; then
      consul_up=1
    else
      sleep 1
    fi
  done
  for node in $(curl -s -X GET http://consul:8500/v1/kv/ethereum_node_?recurse | jq -r .[].Value)
  do
    current=$(echo $node | base64 --decode)
    if [ ${current} != ${enode} ] ; then
      geth --exec "admin.addPeer(${current})" attach
    fi
  done
else
  echo "Consul is disabled"
fi

if [ ! -z "${user_password}" ] ; then
  geth --exec "personal.newAccount('${user_password}')" attach
fi

if [ "${is_miner}" == "true" ] ; then
  geth --exec 'miner.start(1)' attach
fi

wait
