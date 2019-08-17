FROM debian:buster

RUN apt-get update && \
  apt-get install -y curl gnupg2 && \
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

RUN echo "deb http://packages.cloud.google.com/apt cloud-sdk-buster main" > /etc/apt/sources.list.d/gcloud.list && \
  apt-get update && \
  apt-get install -y python-dev python-pip python-setuptools python-openssl python-crcmod python-virtualenv \
    python3-dev python3-pip python3-setuptools python3-openssl python3-crcmod python3-virtualenv \
    virtualenvwrapper sshpass google-cloud-sdk kubectl

ENV WORKON_HOME=/usr/libexec/virtualenv

ADD ansible.sh /tmp/ansible.sh
RUN chmod +x /tmp/ansible.sh && /tmp/ansible.sh && rm /tmp/ansible.sh

ENTRYPOINT ["bash","-l"]
