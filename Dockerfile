FROM alpine:latest as tpm2-build

RUN apk update && apk upgrade && \
  apk add --update alpine-sdk \
    openssl-dev && \
  rm -rf /var/cache/apk/*

RUN mkdir -p /build && \
    cd build && \
    wget https://downloads.sourceforge.net/project/ibmswtpm2/ibmtpm1119.tar.gz && \
    tar -xzf ibmtpm1119.tar.gz && \
    make -C src -j$(nproc)

# The final image running only the simulator
FROM alpine:latest
LABEL maintainer="jehoffma@gmail.com"
LABEL description="TPM2 Simulator"

RUN apk update && apk upgrade && \ 
  apk add --update libssl1.0 && \
  rm -rf /var/cache/apk/*

WORKDIR /tpm2/
COPY --from=tpm2-build /build/src/tpm_server .

EXPOSE 2321
EXPOSE 2322

CMD [ "./tpm_server" ]