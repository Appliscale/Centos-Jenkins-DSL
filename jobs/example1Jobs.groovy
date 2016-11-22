String repo = 'sheehan/grails-example'

job("grails-example-build") {
    scm {
        github repo
    }
    triggers {
        scm 'H/5 * * * *'
    }

}

job("grails-example-deploy") {
    parameters {
        stringParam 'host'
    }
    steps {
        shell 'scp war file; restart...'
    }
}