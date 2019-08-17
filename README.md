# ansible-cloud

Docker images containing multiple ansible version & cloud tools (google
cloud sdk).

Useful in CI role testing to deploy on preemptible instances when using
Docker for testing role is not an option (systemd clumsyness or fidling
with privileged stuff like sysctl).

Python3 is used unless ansible version is below 2.5 (python 2.7 in this
case).

Virtualenv is present so you can switch versions using `workon VERSION`
where `VERSION` is only 'major.minor'. The build process uses the latest
patch version for each selected 'major.minor'.

Pseudo-versions named `latest` & `current` will point respectively to
the latest available ansible version and the version maked as current.
These depend on version set selected in the `ansible.sh` file in the
repository.

See [Docker Hub](https://hub.docker.com/r/devopsworks/ansible-cloud) for
final images.

## Usage

Set `GCLOUD_SERVICE_KEY`, `GOOGLE_PROJECT_ID` and `GOOGLE_COMPUTE_ZONE`
in your CI environment (as secrets !).

gitlab-ci example:

```yaml
ansible-deploy:
  image: devopsworks/ansible-cloud:latest
  stage: test
  before_script:
    - echo $GCLOUD_SERVICE_KEY | gcloud auth activate-service-account --key-file=-
    - gcloud --quiet config set project ${GOOGLE_PROJECT_ID}
    - gcloud --quiet config set compute/zone ${GOOGLE_COMPUTE_ZONE}
  script:
    - workon selected_version
    - do some stuff
```

## Authors

[devopsworks](https://devops.works)

