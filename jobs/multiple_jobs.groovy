import jobBuilder.BaseJobBuilder

String directory = 'Job-examples-2'
folder(directory) {
    description 'Contains more advance job examples'
}

[
    [
        name: 'job-example-1',
        repository: 'file:///home/vagrant/centos-jenkins-dsl/',
        branch: 'master',
        gitTag:'GIT_TAG_1',
        script:'test1.sh'
    ],
    [
        name: 'job-example-2',
        repository: 'file:///home/vagrant/centos-jenkins-dsl/',
        branch: 'master',
        gitTag:'GIT_TAG_2',
        script:'test2.sh'
    ],
    [
        name: 'job-example-3',
        repository: 'file:///home/vagrant/centos-jenkins-dsl/',
        branch: 'master',
        gitTag:'GIT_TAG_3',
        script:'test3.sh'
    ]
].each { Map config ->
    new BaseJobBuilder(
        directory: directory,
        name: config.name,
        repository: config.repository,
        branch: config.branch,
        gitTag: config.gitTag,
        script: config.script,
        gradleTasks: 'clean test'
    ).build(this)
}