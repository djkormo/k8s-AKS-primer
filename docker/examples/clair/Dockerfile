FROM debian:jessie
COPY clair-scanner_linux_amd64 /clair-scanner
RUN chmod +x /clair-scanner
RUN chmod +x /run-scanner.bash
WORKDIR /home
RUN mkdir scanner-logs/
WORKDIR /