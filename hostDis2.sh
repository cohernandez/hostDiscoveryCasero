#!/bin/bash
for port in $(seq 1 65535); do
    proxychains bash -c "timeout 1 echo ' ' > /dev/tcp/10.197.243.31/$port" 2>/dev/null && echo "[+] Puerto $port Abierto" &
done
wait
