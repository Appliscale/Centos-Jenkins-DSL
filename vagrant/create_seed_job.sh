#!/usr/bin/env bash

SYNC_FOLDER=centos-jenkins-dsl/vagrant
JENKINS_PORT=9001
JENKINS_PASS=$( sudo cat /var/lib/jenkins/secrets/initialAdminPassword )

# Create seed job
java -jar /home/vagrant/$SYNC_FOLDER/jenkins-cli.jar -s http://127.0.0.1:${JENKINS_PORT}/ \
create-job seed_job < /home/vagrant/$SYNC_FOLDER/seed_job.xml --username admin --password $JENKINS_PASS