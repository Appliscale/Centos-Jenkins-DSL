<img src="https://upload.wikimedia.org/wikipedia/commons/8/87/Vagrant.png" width="100">
<img src="https://wiki.centos.org/ArtWork/Brand/Logo?action=AttachFile&do=get&target=centos-logo-light-rtm.svg" width="150">
<img src="http://ftp.icm.edu.pl/packages/jenkins/art/jenkins-logo/256x256/logo+title.png" width="150">
<img src="https://upload.wikimedia.org/wikipedia/commons/3/36/Groovy-logo.svg" width="120">

## Centos-Jenkins-DSL
This project was created in order to test Jenkins Job DSL plugin and to provide local instance of Jenkins for experiments - before we deploy our jobs on production we need to check if they are working correctly. Centos-Jenkins-DSL is exactly that, after you set up everything you will get your own Jenkins instance on Centos 7 available at http://localhost:9001 with seed job pointing to this local git repository where you store your configuration.

<p align="center">
<img src="https://github.com/mwpolcik/mwpolcik.github.io/blob/master/Diagram_Jenkins_DSL_Centos.png" width="500">
</p>

## End Result
This is how creating many jobs from one seed job looks like:

<img src="https://github.com/mwpolcik/mwpolcik.github.io/blob/master/Jenkins-DSL.gif">

## Requirements
   vagrant:    [Instructions](https://www.vagrantup.com/docs/installation/) 
   
   virtualbox: [Instructions](https://www.virtualbox.org/wiki/Downloads)
   
## How to use
**All `vagrant` commands must be run from `vagrant` directory on host machine.** 

After successful instalation of Vagrant and VirtualBox it's time to run the project: 
```bash
$ git clone git@github.com:mwpolcik/Centos-Jenkins-DSL.git
$ cd vagrant
# This may take few minutes
$ vagrant up
```
In order to save the machine for later use run:
```bash
$ vagrant suspend
```
In case you want to completely get rid of VM run:
```bash
$ vagrant destroy
```
## What's inside
```
├── jobs
├── src
│    ├── main
│    └── test
└── vagrant
├── gradlew
```
## jobs - dir
This folder contains dsl scripts that will be used to create Jenkins jobs. Seed job will run .groovy files located in this directory and build new jobs based on your configuration. 

## src - dir
   - main contains classes used for job creation
   - test contains classes used for testing dsl groovy scripts and building xml files

## gradlew - script
The gradle wrapper used for invoking tests, usage:
```bash
./gradlew test
```
After that you will find config.xml files for each job in `build/debug-xml/jobs/'.

## vagrant -dir
### Vagrantfile
VM will be created with following parameters from Vagrantfile:

    - box: centos/7
    - box version: >=1609.1 (3.10.0-327.36.3.el7.x86_64)
    - port: 9001
    - memory: 1048
    - cpu: 1
    - provision: bootstrap.sh
You can modify every option in Vagrantfile, but keep in mind that this Jenkins instance is set to run on port 9001(default is 8080). In case you want to switch to different port, then you also need to modify variable `JENKINS_PORT` in `vagrant/bootstrap.sh`.

### bootstrap.sh
This script is responsible for provisioning VM, installing and configuring Jenkins, etc.. Following parameters are located at the beginning of the file:
    - JAVA_VERSION=1.8.0
    - JENKINS_VERSION=2.62
    - JENKINS_HOME=/var/lib/jenkins
    - JENKINS_PORT=9001
    - SYNC_FOLDER=centos-jenkins-dsl/vagrant
    
In order to log in into Jenkins there you can use two users:

    1. admin - password generated during installation and displayed at the end of installation.
    2. Created in bootstrap.sh via jenkins-cli: `admin2/123456`.

### install_plugins.sh
This script is responsible for installing Jenkins plugins.
In case some of them weren't installed during provisioning process log in into VM and run it manually:
```bash
$ vagrant ssh
$ cd centos-jenkins-dsl/vagrant/
$ ./install_plugins.sh
```
In order to add additinal plugin edit this file add one to the `plugins` array:
```bash
plugins=(
    git
    timestamper
    ssh
    github
    ...
    new-plugin
)
```
### seed_job.xml
During provisioning process this file will be used to create seed job via `jenkins-cli`.

## Troubleshooting
### Plugin installation
Discussed earlier - check [install_plugin.sh](#install_pluginssh) under vagrant section.
### Seed Job
It's possible that seed job will not be created at first - in this case run followng command in your terminal:
```bash
$ vagrant ssh
$ cd centos-jenkins-dsl/vagrant
$ ./create_seed_job.sh
```
### Jenkins rpm
Sometimes all rpm mirrors are not available and you may need to wait a bit (about 1h) for them to kick in. Another solution is to get rpm from another source, in this case you need to copy the file into vagrant directory and remember to change its name to following format:
`jenkins-NUMBER.rpm` - NUMBER must be replaced by the value of `JENKINS_VERSION` variable you have in `bootstrap.sh` file - default is 2.33.
### Reinstall
In case you had some problems during initial provisioning run following command from `vagrant` directory on host machine:
```bash
$ vagrant provision
```

### Disable script security for Job DSL scripts
From job-dsl 1.60 version you need to approve the scripts if you want to run `seed_job`. There is an additional build step - tiny groovy snippet - in `seed_job.xml` which will disable script security for Job DSL scripts: 
```groovy
import javaposse.jobdsl.plugin.GlobalJobDslSecurityConfiguration
import jenkins.model.GlobalConfiguration

GlobalConfiguration.all().get(GlobalJobDslSecurityConfiguration.class).useScriptSecurity=false
```
In case you want to disable security `feature` in production environment you should check available options here:
https://github.com/jenkinsci/job-dsl-plugin/wiki/Migration#migrating-to-160

You can also disable it by going to Manage Jenkins -> Global Configuration -> uncheck `Enable script security for Job DSL scripts`.

## Source

Initial project was based on examples presented in this repository:
- https://github.com/sheehan/job-dsl-gradle-example

## Jenkins
Official Jenkins website:
https://jenkins.io/

## Job Dsl Plugin
Link to plugin:
- https://wiki.jenkins-ci.org/display/JENKINS/Job+DSL+Plugin

Documentation for Job Dsl Plugin **recommended** by all means: 
- https://jenkinsci.github.io/job-dsl-plugin/ 
