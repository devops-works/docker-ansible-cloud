#!/bin/bash


# This script will install several ansible versions using virtualenv.
# Versions installed are determined by several variables:

export ANSIBLE_MIN_VERSION=2.3
#export ANSIBLE_VERSIONS="2.8 2.6 2.3"
export ANSIBLE_VERSIONS="2.8 2.7 2.6 2.5 2.4 2.3"

# If you do not define ANSIBLE_VERSIONS; all ansible minor versions will be installed
# starting from ANSIBLE_MIN_VERSION (this last variable has no other use besides that)
# Versions are installed in virtualenv named "X.Y" (e.g. 2.5).

export ANSIBLE_CURRENT_VERSION=2.8

# Virtualenvs named "current" and "future" will contain version listed
# respectively in ANSIBLE_CURRENT_VERSION and ANSIBLE_FUTURE_VERSION. "current"
# is supposed to be the version currently used in production, while "future"
# should match next release that will be used in production (this is not
# compulsory; it can be the same version as ANSIBLE_CURRENT_VERSION).
#
# An additional virtualenv named "latest" will be created, containing the latest
# ansible available at build time.
#
# ---- no need to customize below unless fixes required ----

if [ -z "$ANSIBLE_VERSIONS" ]; then
  ANSIBLE_VERSIONS=$(pip install ansible==0.0.0  2>&1 | \
    grep "from versions" | \
    sed -e 's/.*: \(.*\))/\1/' | \
    tr -d ',' | \
    sed -e "s/.*\($ANSIBLE_MIN_VERSION\)/\1/" | \
    tr ' ' '\n' | \
    grep -v '[a-z]' | \
    cut -f1,2 -d'.' | \
    sort | \
    uniq
  )
else
  ANSIBLE_VERSIONS=$(echo $ANSIBLE_VERSIONS | tr ' ' '\n' | sort)
fi

export ANSIBLE_MAX_VERSION=$(echo "${ANSIBLE_VERSIONS}" | tail -1)

vercomp () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}


# Warning: virtualenv naming scheme has an impact on docker containers used in travis
# They are designed to "workon" ansible-${ver}
#
echo "####### Environments #######"

echo "CURRENT is ${ANSIBLE_CURRENT_VERSION}"
echo "MAX is ${ANSIBLE_MAX_VERSION}"
echo -e "The following versions will be installed:\n${ANSIBLE_VERSIONS}"

mkdir -p /usr/libexec/virtualenv

# echo "WORKON_HOME=/usr/libexec/virtualenv" >> /etc/environment
#echo "source /usr/share/virtualenvwrapper/virtualenvwrapper_lazy.sh" >> /etc/environment

source /etc/bash_completion.d/virtualenvwrapper

for ver in $ANSIBLE_VERSIONS; do
  vercomp ${ver} '2.5'
  if [ $? -eq 1 ]; then
    echo -e "> Installing ansible version $ver (python3)"
    mkvirtualenv ${ver} -p /usr/bin/python3 --no-site-packages > /dev/null 2>&1
  else
    echo -e "> Installing ansible version $ver (python2)"
    mkvirtualenv ${ver} -p /usr/bin/python2 --no-site-packages > /dev/null 2>&1
  fi
  workon ${ver}
  pip install -q packaging appdirs six paramiko PyYAML Jinja2 httplib2 docker-py netaddr ipaddr ansible~=${ver}.0 ansible-lint yamllint ansible-inventory-grapher boto boto3

  cpvirtualenv ${ver} $(echo ${ver} | cut -f1-2 -d'.') > /dev/null 2>&1

  if [ ${ANSIBLE_CURRENT_VERSION} == ${ver} ]; then
    echo "> Setting 'current' venv to ${ver}"
    cpvirtualenv ${ver} current > /dev/null 2>&1
  fi
  if [ ${ANSIBLE_MAX_VERSION} == ${ver} ]; then
    echo "> Setting 'latest' venv to ${ver}"
    cpvirtualenv ${ver} latest > /dev/null 2>&1
  fi
  chmod -R 777 /usr/libexec/virtualenv/
done

#ln -sf /dev/null /usr/libexec/virtualenv/hook.log
