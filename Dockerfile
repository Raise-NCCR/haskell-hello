FROM ubuntu:20.04
RUN mkdir -p /opt/hello/
ARG BINARY_PATH
WORKDIR /opt/hello
RUN echo 'nameserver 8.8.8.8' >> /etc/resolv.conf && \
  apt-get update && apt-get install -y \
  ca-certificates \
  libgmp-dev
COPY "$BINARY_PATH" /opt/hello
CMD ["/opt/hello/hello-exe"]