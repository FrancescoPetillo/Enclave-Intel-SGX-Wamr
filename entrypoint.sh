#!/bin/bash
set -e

echo "[Entrypoint] Avvio container SGX + WAMR + IPFS + OSSEC + wolfSSL"

# 1. Carica ambiente SGX SDK
if [ -f /opt/intel/sgxsdk/environment ]; then
  source /opt/intel/sgxsdk/environment
  echo "[Entrypoint] SGX SDK caricato (SIM mode)."
fi

# 2. Avvia AESM (anche in SIM è richiesto)
mkdir -p /var/run/aesmd
/opt/intel/sgxpsw/aesm/aesm_service &

# 3. Avvia OSSEC
if [ -x /var/ossec/bin/ossec-control ]; then
  /var/ossec/bin/ossec-control start || true
  echo "[Entrypoint] OSSEC avviato."
fi

# 4. Inizializza IPFS se non ancora configurato
if [ ! -d /root/.ipfs ]; then
  echo "[Entrypoint] Inizializzo repo IPFS..."
  ipfs init
  ipfs config Addresses.API /ip4/0.0.0.0/tcp/5001
  ipfs config Addresses.Gateway /ip4/0.0.0.0/tcp/8080
  ipfs config Addresses.Swarm --json '[
    "/ip4/0.0.0.0/tcp/4001",
    "/ip4/0.0.0.0/udp/4001/quic-v1"
  ]'
fi

# 5. Avvia demone IPFS
ipfs daemon --migrate=true 2>&1 | tee /var/log/ipfs.log &

# 6. Avvia comando richiesto
exec "$@"
