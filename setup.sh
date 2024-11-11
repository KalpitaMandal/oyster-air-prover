#!/bin/sh

# setting an address for loopback
ifconfig lo 127.0.0.1
ifconfig

# adding a default route
ip route add default dev lo src 127.0.0.1
route -n

# iptables rules to route traffic to transparent proxy
iptables -A OUTPUT -t nat -p tcp --dport 1:65535 ! -d 127.0.0.1  -j DNAT --to-destination 127.0.0.1:1200
iptables -t nat -A POSTROUTING -o lo -s 0.0.0.0 -j SNAT --to-source 127.0.0.1
iptables -L -t nat

# generate identity key
# /app/keygen --secret /app/id.sec --public /app/id.pub
# /app/oyster-keygen --secret /app/secp.sec --public /app/secp.pub

ls app
# cat /app/id.sec
# cat /app/secp.sec

/app/cpu_air_prover \
    --out_file=/app/fibonacci_proof.json \
    --private_input_file=/app/fibonacci_private_input.json \
    --public_input_file=/app/fibonacci_public_input.json \
    --prover_config_file=/app/cpu_air_prover_config.json \
    --parameter_file=/app/cpu_air_params.json

/app/cpu_air_verifier --in_file=/app/fibonacci_proof.json && echo "Successfully verified example proof."

# starting supervisord
/app/supervisord
