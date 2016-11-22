#!/usr/bin/env bash

WORK_DIR=/home/vagrant/centos-jenkins-dsl/vagrant
JENKINS_PORT=9001
NUMBER_OF_RETRIES=4
if [ $# -eq 0 ]; then
    JENKINS_PASS=$( sudo cat /var/lib/jenkins/secrets/initialAdminPassword )
else
    JENKINS_PASS=$1
fi

function install_plugin {
    COUNTER=0
    while true;do
        plugin=$1
        java -jar $WORK_DIR/jenkins-cli.jar -s http://127.0.0.1:$JENKINS_PORT/ install-plugin $plugin --username admin --password $JENKINS_PASS
        rc=$?
        if [ $COUNTER -eq $NUMBER_OF_RETRIES ]; then
            echo -e "\e[31mCound't install $plugin\e[0m"
            break
        elif [ $rc -ne 0 ]; then
            COUNTER=$((COUNTER+1))
            echo -e "\e[33mRetrying $COUNTER\e[0m"
            sleep 5s
        elif [ $rc -eq 0 ];then
            echo -e "\e[32m ${plugin} installed\e[0m"
            break
        fi
    done
}

plugins=(
    git
    timestamper
    ssh
    github
    ssh-agent
    greenballs
    job-dsl
    validating-string-parameter
    rebuild
    jobConfigHistory
    cloudbees-folder
    gradle 
    chucknorris
    )

for plugin in "${plugins[@]}"
do
    install_plugin $plugin
done

sudo systemctl restart jenkins.service
echo "Restarting jenkins ... break for 30s"
sleep 30s