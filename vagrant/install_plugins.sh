#!/usr/bin/env bash

WORK_DIR=/home/vagrant/centos-jenkins-dsl/vagrant
JENKINS_PORT=9001
if [ $# -eq 0 ]; then
    JENKINS_PASS=$( sudo cat /var/lib/jenkins/secrets/initialAdminPassword )
else
    JENKINS_PASS=$1
fi

function install_plugin {
    plugin=$1
    java -jar $WORK_DIR/jenkins-cli.jar -s http://127.0.0.1:$JENKINS_PORT/ install-plugin $plugin --username admin --password $JENKINS_PASS
}

function restart_jenkins {
    sudo systemctl restart jenkins.service
    sleep 30s
}

plugins=(
    github
    timestamper
    ssh-agent
    shiningpanda
    greenballs
    job-dsl
    envinject
    rebuild
    jobConfigHistory
    # cloudbees-folder
    ssh
    chucknorris
    workflow-aggregator
    )

for plugin in "${plugins[@]}"
do
    install_plugin $plugin
done

restart_jenkins