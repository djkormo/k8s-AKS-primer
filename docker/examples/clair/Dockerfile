FROM debian:jessie
COPY clair-scanner_linux_amd64 /clair-scanner
COPY run-scanner.bash /run-scanner.bash
RUN chmod +x /clair-scanner
RUN chmod +x /run-scanner.bash
WORKDIR /home
RUN mkdir scanner-logs/
WORKDIR /