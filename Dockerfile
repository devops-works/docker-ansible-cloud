FROM debian:buster-slim

ENV WORKON_HOME=/usr/libexec/virtualenv

ADD ansible.sh /tmp/ansible.sh
ADD entrypoint.sh /usr/local/bin/entrypoint.sh

RUN apt-get update \
  && apt-get install -y curl gnupg2 \
  && echo "deb http://packages.cloud.google.com/apt cloud-sdk-buster main" > /etc/apt/sources.list.d/gcloud.list \
  && curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
  && apt-get update \
  && apt-get install -y python-dev python-pip python-setuptools python-openssl python-crcmod python-virtualenv \
      python3-dev python3-pip python3-setuptools python3-openssl python3-crcmod python3-virtualenv \
      virtualenvwrapper sshpass google-cloud-sdk kubectl \
  && rm -rf /var/lib/apt/lists/* \
  && chmod +x /tmp/ansible.sh && /tmp/ansible.sh && rm /tmp/ansible.sh \
  && chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
