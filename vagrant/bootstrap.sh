#!/usr/bin/env bash

JAVA_VERSION=1.7.0
JENKINS_VERSION=2.28
JENKINS_HOME=/var/lib/jenkins
JENKINS_PORT=9001
GROOVY_VERSION=2.4.7
SYNC_FOLDER=centos-jenkins-dsl/vagrant
# Default user for jenkins
USER_NAME="admin2"
USER_PASS="123456"
# Update
sudo yum install epel-release
sudo yum update

# Install tools
sudo yum install -y wget
sudo yum install -y git
sudo yum install -y unzip
sudo yum install -y vim

# Install Java
sudo yum install -y java-${JAVA_VERSION}-openjdk.x86_64
java -version

JAVA_HOME_ENV=JAVA_HOME=/usr/lib/jvm/jre-${JAVA_VERSION}-openjdk
JRE_HOME_ENV=JRE_HOME=/usr/lib/jvm/jre
sudo cp /etc/profile /etc/profile_backup

if [ "$JAVA_HOME" = "" ]; then
	echo "export $JAVA_HOME_ENV" | sudo tee -a /etc/profile
fi		

if [ "$JRE_HOME" = "" ]; then
	echo "export $JRE_HOME_ENV" | sudo tee -a /etc/profile
fi

source /etc/profile

echo $JAVA_HOME
echo $JRE_HOME

## SDKMAN installation
#curl -s get.sdkman.io > $HOME/install_sdk.sh
#sh install_sdk.sh
#source "$HOME/.sdkman/bin/sdkman-init.sh"
# Groovy installation
#yes y | sdk install groovy $GROOVY_VERSION
#groovy -version

JENKINS_RPM=jenkins-${JENKINS_VERSION}.rpm

if [[ ! -d $SYNC_FOLDER ]]; then
	mkdir $SYNC_FOLDER
fi

# Download Jenkins
if [[ ! -e $SYNC_FOLDER/$JENKINS_RPM  ]]; then
	sudo wget --progress=bar:force -O $SYNC_FOLDER/$JENKINS_RPM http://pkg.jenkins-ci.org/redhat/jenkins-${JENKINS_VERSION}-1.1.noarch.rpm
fi

if ! rpm -qa | grep -qw jenkins; then
    # Install Jenkins
	sudo rpm -ivh $SYNC_FOLDER/$JENKINS_RPM
	echo "Jenkins installed"

    # Run Jenkins under vagrant user
    echo "Setting Jenkins to run under vagrant user"
    sudo sed -i -e 's/JENKINS_USER="jenkins"/JENKINS_USER="vagrant"/g' /etc/sysconfig/jenkins
    sudo chown -R vagrant:vagrant /var/lib/jenkins
    sudo chown -R vagrant:vagrant /var/cache/jenkins
    sudo chown -R vagrant:vagrant /var/log/jenkins
    
    # Change Jenkins port
    sudo sed -i "/JENKINS_PORT/c\JENKINS_PORT="${JENKINS_PORT}"" /etc/sysconfig/jenkins

    # Start jenkins
    sudo systemctl start jenkins.service
    # Enable on startup
    sudo systemctl enable jenkins.service
    sleep 10s
fi

JENKINS_CLI=$SYNC_FOLDER/jenkins-cli.jar
# Remove old jenkins cli
if [ -f $JENKINS_CLI ];then
    echo "Removing old jenkins cli..."
    rm $JENKINS_CLI
fi

# Wait for jenkins to start and download cli
echo "Downloading jenkins-cli.jar"
while true;do
    wget --quiet -P $SYNC_FOLDER/  http://localhost:${JENKINS_PORT}/jnlpJars/jenkins-cli.jar
    rc=$?
    sleep 5s
    if [ "$WGET_TIMEOUT" -eq "10" ]; then
        echo "Failed to download"
        break
    elif [ "$rc" -ne "0" ]; then
        echo "$(($WGET_TIMEOUT+1)) retry ..."
        WGET_TIMEOUT=$((WGET_TIMEOUT + 1))
    elif [ -f $JENKINS_CLI ]; then
        echo "jenkins-cli.jar downloaded"
        break
    fi  
done


# Unlock jenkins
JENKINS_UNLOCK_FILE=$JENKINS_HOME/jenkins.install.InstallUtil.lastExecVersion
if [ ! -f $JENKINS_UNLOCK_FILE ]; then
   echo "$JENKINS_VERSION" | sudo tee -a $JENKINS_UNLOCK_FILE 
   sudo systemctl restart jenkins.service
   sleep 10s
fi

JENKINS_PASS=$( sudo cat /var/lib/jenkins/secrets/initialAdminPassword )

# # Create new user
echo "Creating new user ..."
echo "jenkins.model.Jenkins.instance.securityRealm.createAccount('$USER_NAME', '$USER_PASS')" | java \
-jar $SYNC_FOLDER/jenkins-cli.jar -s http://localhost:${JENKINS_PORT}/ groovy = --username admin --password $JENKINS_PASS

# Install jenkins plugins - in case of any errors just re-run 
# this script from vagrant machine in the directory with jenkins-cli.jar
# default location: /home/vagrant/centos-jenkins-dsl/vagrant
bash $SYNC_FOLDER/install_plugins.sh $JENKINS_PASS

# Create seed job
java -jar $SYNC_FOLDER/jenkins-cli.jar -s http://127.0.0.1:${JENKINS_PORT}/ \
create-job seed_job < $SYNC_FOLDER/seed_job.xml --username admin --password $JENKINS_PASS

# # Print logins
echo "Users: "
echo "Login: admin"
echo "Password: $JENKINS_PASS"
echo "Login: $USER_NAME"
echo "Password: $USER_PASS" 