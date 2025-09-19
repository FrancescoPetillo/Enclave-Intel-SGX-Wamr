FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# --- Pacchetti base ---
RUN apt-get update && apt-get install -y \
    git build-essential autoconf automake libtool pkg-config \
    ca-certificates wget curl cmake python3 tar libssl-dev vim \
    && rm -rf /var/lib/apt/lists/*

# --- Intel SGX SDK (modalità SIM) ---
WORKDIR /opt
RUN wget https://download.01.org/intel-sgx/sgx-linux/2.19/distro/ubuntu20.04-server/sgx_linux_x64_sdk_2.19.100.3.bin && \
    chmod +x sgx_linux_x64_sdk_2.19.100.3.bin && \
    echo "yes" | ./sgx_linux_x64_sdk_2.19.100.3.bin && \
    rm sgx_linux_x64_sdk_2.19.100.3.bin
ENV SGX_SDK=/opt/intel/sgxsdk
ENV PATH=$SGX_SDK/bin:$PATH
ENV LD_LIBRARY_PATH=$SGX_SDK/lib64:$LD_LIBRARY_PATH

# --- wolfSSL (SGX static build) ---
WORKDIR /root
RUN git clone https://github.com/wolfSSL/wolfssl.git && \
    cd wolfssl && ./autogen.sh && ./configure && ./config.status && \
    cd IDE/LINUX-SGX && make -f sgx_t_static.mk clean || true && \
    make -B -f sgx_t_static.mk HAVE_WOLFSSL_TEST=1 HAVE_WOLFSSL_BENCHMARK=1 V=1

# --- WAMR (WebAssembly Micro Runtime con WASI) ---
WORKDIR /root
RUN git clone https://github.com/bytecodealliance/wasm-micro-runtime.git && \
    cd wasm-micro-runtime/product-mini/platforms/linux-sgx && \
    cmake -DWAMR_BUILD_LIBC_WASI=1 . && \
    make -j"$(nproc)" && cp iwasm /usr/local/bin/

# --- WASI SDK ---
WORKDIR /opt
RUN wget https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-20/wasi-sdk-20.0-linux.tar.gz && \
    tar -xzf wasi-sdk-20.0-linux.tar.gz && mv wasi-sdk-20.0 wasi-sdk && rm wasi-sdk-20.0-linux.tar.gz
ENV WASI_SDK_PATH=/opt/wasi-sdk

# --- IPFS (Kubo) ---
WORKDIR /usr/local
RUN wget https://dist.ipfs.tech/kubo/v0.18.1/kubo_v0.18.1_linux-amd64.tar.gz && \
    tar -xvzf kubo_v0.18.1_linux-amd64.tar.gz && \
    cd kubo && bash install.sh && cd .. && rm -rf kubo kubo_v0.18.1_linux-amd64.tar.gz

# --- OSSEC HIDS ---
WORKDIR /root
RUN wget -O - https://github.com/ossec/ossec-hids/archive/3.7.0.tar.gz | tar zx && \
    cd ossec-hids-3.7.0 && \
    echo -e "en\nno\n/var/ossec\n\n\n\n\n" | ./install.sh

# --- Directory di lavoro e entrypoint ---
WORKDIR /usr/src/app
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
