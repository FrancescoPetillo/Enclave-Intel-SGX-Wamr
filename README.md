📄 README.md
# SGX + WAMR + IPFS + OSSEC Project

Questo progetto dimostra l’esecuzione sicura di moduli WebAssembly (WASM) in un ambiente **Intel SGX (modalità SIM)**, utilizzando il runtime **WAMR**, con pipeline di scrittura su filesystem → pubblicazione su **IPFS**, e monitoraggio tramite **OSSEC HIDS**.  
Include inoltre la build statica di **wolfSSL** per future estensioni TLS/attestation.

---

# Per il README completo utilizzare "README(completo).md"

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

📚 Documentazione

Relazione tecnica completa in docs/Relazione_Tecnica.pdf
Slide di presentazione in docs/slides.pptx

👥 Autori

Francesco Petillo
Gabriele Esposito

Università degli Studi di Napoli Parthenope
Corso: Sicurezza dei Sistemi Operativi e Cloud – A.A. 2024/2025
