FROM debian:jessie

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install \
  curl

#ARG KUBECTL_URL=https://storage.googleapis.com/kubernetes-release/release/v1.13.0/bin/linux/amd64/kubectl
#RUN cd /usr/local/bin && curl -O $KUBECTL_URL && chmod 755 kubectl
# download lates version of kubectl
RUN cd /usr/local/bin  \
  && curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl \
  && chmod 755 kubectl 


WORKDIR /usr/src/app
COPY chaos-pod.bash ./ 
# workaround for ending lines in Windows
RUN sed -i -e 's/\r$//' /usr/src/app/chaos-pod.bash
ENTRYPOINT ["/bin/bash", "-c", "/usr/src/app/chaos-pod.bash"]