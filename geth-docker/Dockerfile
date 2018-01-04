FROM ubuntu:latest
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update &&  apt-get install -qy curl jq software-properties-common supervisor
RUN add-apt-repository -y ppa:ethereum/ethereum
RUN apt-get update && apt-get install -qy ethereum

RUN useradd geth -g users -m &&\
    mkdir /geth &&\
    chown geth: /geth

ENV networkid 10000
ENV geth_command "geth --rpc --rpcapi eth,net,web3,personal --rpcaddr 0.0.0.0 -networkid ${networkid} --nodiscover console+"
ENV is_miner false
ENV use_consul true

ADD resources/genesis.json /tmp/genesis.json
ADD resources/supervisord.conf /etc/supervisor/supervisord.conf
ADD resources/start.sh /geth/start.sh
RUN chmod +x /geth/start.sh

WORKDIR /geth
USER geth

RUN geth init /tmp/genesis.json

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
