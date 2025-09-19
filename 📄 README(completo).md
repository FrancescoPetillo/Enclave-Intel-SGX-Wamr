📄 README.md
# SGX + WAMR + IPFS + OSSEC Project

Questo progetto dimostra l’esecuzione sicura di moduli WebAssembly (WASM) in un ambiente **Intel SGX (modalità SIM)**, utilizzando il runtime **WAMR**, con pipeline di scrittura su filesystem → pubblicazione su **IPFS**, e monitoraggio tramite **OSSEC HIDS**.  
Include inoltre la build statica di **wolfSSL** per future estensioni TLS/attestation.

---

## 📦 Struttura del progetto
.
├── Dockerfile # immagine completa (SGX + WAMR + WASI + IPFS + OSSEC + wolfSSL)
├── entrypoint.sh # avvio automatico servizi (SGX, IPFS, OSSEC)
├── src/ # esempi WASM e codice C
│ ├── write.c
│ └── write.wasm
├── docs/ # documentazione
│ ├── Relazione_Tecnica.pdf
│ └── slides.pptx
└── README.md


---

## 🚀 Build dell’immagine

Costruisci l’immagine Docker a partire dal `Dockerfile`:

```bash
docker build -t sgx-ipfs-app .

▶️ Avvio del container

Esegui il container con porte e volumi configurati:

docker run -it --name sgx-ipfs-app \
  -p 4001:4001 -p 4001:4001/udp \
  -p 5001:5001 -p 8080:8080 \
  -v $(pwd):/usr/src/app \
  sgx-ipfs-app


Al primo avvio l’entrypoint.sh inizializza:

Intel SGX SDK (SIM mode)
AESM service
OSSEC HIDS
Repo IPFS (API + Gateway)
Avvia IPFS daemon in background

🧪 Test rapido
1. Compilare un programma C in WASM (con WASI SDK)

Esempio write.c:

#include <stdio.h>
#include <string.h>
int main(int argc, char** argv) {
  const char *out = "out.txt";
  const char *msg = (argc>1)? argv[1] : "Hello from WAMR + SGX (SIM)!\n";
  FILE *f = fopen(out, "w");
  if (!f) { perror("fopen"); return 1; }
  fwrite(msg, 1, strlen(msg), f);
  fclose(f);
  return 0;
}


Compilazione:

/opt/wasi-sdk/bin/clang --target=wasm32-wasi -O2 -o write.wasm write.c

2. Eseguire con WAMR (SGX SIM)
iwasm --dir=. write.wasm "Prova pipeline SGX+WAMR+IPFS"
cat out.txt

3. Pubblicare su IPFS
CID=$(ipfs add -Q out.txt)
echo "CID: $CID"

# Recupero via Gateway
curl "http://127.0.0.1:8080/ipfs/$CID"

4. Monitoraggio OSSEC

OSSEC è configurato per monitorare:

modifiche a out.txt
anomalie nei log /var/log/ipfs.log

Esempio:
echo "tamper $(date)" >> out.txt
tail -n 50 /var/ossec/logs/alerts/alerts.log

⚙️ Tecnologie usate

Intel SGX SDK (modalità SIM)
WAMR (WebAssembly Micro Runtime) con supporto WASI
WASI SDK
IPFS (Kubo)
OSSEC HIDS
wolfSSL (SGX static build, predisposto)

📚 Documentazione

Relazione tecnica completa in docs/Relazione_Tecnica.pdf
Slide di presentazione in docs/slides.pptx

👥 Autori

Francesco Petillo
Gabriele Esposito

Università degli Studi di Napoli Parthenope
Corso: Sicurezza dei Sistemi Operativi e Cloud – A.A. 2024/2025
