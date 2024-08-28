FROM ubuntu:jammy
RUN apt update && apt install -y rsync ssh
RUN useradd -m awxbackup
RUN mkdir /home/awxbackup/.ssh && touch /home/awxbackup/.ssh/authorized_keys
RUN chmod 700 /home/awxbackup/.ssh && chmod 600 /home/awxbackup/.ssh/authorized_keys
RUN chown -R awxbackup:awxbackup /home/awxbackup
USER awxbackup
WORKDIR /home/awxbackup
