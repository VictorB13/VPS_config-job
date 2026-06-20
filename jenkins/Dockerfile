FROM jenkins/jenkins:lts
USER root
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \ 
    python3-virtualenv \ 
    sshpass \ 
    && rm -rf /var/lib/apt/lists/*
RUN pip3 install ansible havc --break-system-packages
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt
USER jenkins