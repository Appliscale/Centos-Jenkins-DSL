import com.dslexample.StepsUtil

job("static-method-example1") {

    steps {
        gradle {
            useWrapper true
            tasks 'clean test'
            switches '''
                -Dhttp.proxyHost=proxy.example.com
                -Dhttps.proxyHost=proxy.example.com
                -Dhttp.proxyPort=80
                -Dhttps.proxyPort=80
            '''
        }
    }
}

job("static-method-example2") {

    steps {
        StepsUtil.proxiedGradle delegate, 'clean test'
    }
}

