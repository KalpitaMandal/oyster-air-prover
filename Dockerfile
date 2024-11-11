# base image
FROM ciimage/python:3.9 as base_image

RUN apt update
# RUN apt install -y python3.9-dev git wget gnupg2 elfutils libdw-dev python3-pip libgmp3-dev unzip
# install dependency tools
RUN apt install -y net-tools iptables iproute2 wget 
# RUN pip install fastecdsa

# Install Cairo0 for end-to-end test.
# RUN pip install cairo-lang==0.13.2

# RUN pip install --upgrade pip
# RUN pip install cpplint pytest numpy

# RUN apt install -y clang-12 clang-format-12 clang-tidy-6.0 libclang-12-dev llvm-12

# COPY docker_common_deps.sh /app/
# WORKDIR /app/
# RUN ./docker_common_deps.sh
# RUN chown -R starkware:starkware /app

# working directory
WORKDIR /app

# supervisord to manage programs
RUN wget -O supervisord http://public.artifacts.marlin.pro/projects/enclaves/supervisord_master_linux_amd64
RUN chmod +x supervisord

# transparent proxy component inside the enclave to enable outgoing connections
RUN wget -O ip-to-vsock-transparent http://public.artifacts.marlin.pro/projects/enclaves/ip-to-vsock-transparent_v1.0.0_linux_amd64
RUN chmod +x ip-to-vsock-transparent

# key generator to generate static keys
RUN wget -O keygen http://public.artifacts.marlin.pro/projects/enclaves/keygen_v1.0.0_linux_amd64
RUN chmod +x keygen

# attestation server inside the enclave that generates attestations
RUN wget -O attestation-server http://public.artifacts.marlin.pro/projects/enclaves/attestation-server_v2.0.0_linux_amd64
RUN chmod +x attestation-server

# proxy to expose attestation server outside the enclave
RUN wget -O vsock-to-ip http://public.artifacts.marlin.pro/projects/enclaves/vsock-to-ip_v1.0.0_linux_amd64
RUN chmod +x vsock-to-ip

# dnsproxy to provide DNS services inside the enclave
RUN wget -O dnsproxy http://public.artifacts.marlin.pro/projects/enclaves/dnsproxy_v0.46.5_linux_amd64
RUN chmod +x dnsproxy

RUN wget -O oyster-keygen http://public.artifacts.marlin.pro/projects/enclaves/keygen-secp256k1_v1.0.0_linux_amd64
RUN chmod +x oyster-keygen

# supervisord config
COPY supervisord.conf /etc/supervisord.conf

# setup.sh script that will act as entrypoint
COPY setup.sh ./
RUN chmod +x setup.sh

COPY cpu_air_prover ./
RUN chmod +x cpu_air_prover

COPY cpu_air_verifier ./
RUN chmod +x cpu_air_verifier

COPY fibonacci_private_input.json ./
RUN chmod +x fibonacci_private_input.json

COPY fibonacci_public_input.json ./
RUN chmod +x fibonacci_public_input.json

COPY cpu_air_prover_config.json ./
RUN chmod +x cpu_air_prover_config.json

COPY cpu_air_params.json ./
RUN chmod +x cpu_air_params.json

RUN /app/cpu_air_prover \
    --out_file=/app/fibonacci_proof.json \
    --private_input_file=/app/fibonacci_private_input.json \
    --public_input_file=/app/fibonacci_public_input.json \
    --prover_config_file=/app/cpu_air_prover_config.json \
    --parameter_file=/app/cpu_air_params.json

RUN /app/cpu_air_verifier --in_file=/app/fibonacci_proof.json && echo "Successfully verified example proof."

# entry point
ENTRYPOINT [ "/app/setup.sh" ]
