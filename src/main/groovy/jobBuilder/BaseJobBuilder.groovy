package jobBuilder

import javaposse.jobdsl.dsl.DslFactory
import javaposse.jobdsl.dsl.Job
import static jobBuilder.Utils.Param.requiredString
import jobBuilder.Utils.Steps
import jobBuilder.Utils.Scm

class BaseJobBuilder {

    String name
    String repository
    String branch
    String gitTag
    String dirWithScripts = 'jobs/scripts/'
    String script
    String directory
    String gradleTasks
    Job job

    void build(DslFactory dslFactory) {
        this.job = dslFactory.job(directory+"/"+name) {
            logRotator(2, 10, -1, -1)
            scm {
                Scm.git(delegate,repository,branch)
            }
            parameters {
                booleanParam 'NOTIFY_QA', true, ""
            }
            configure requiredString(gitTag)
            steps {
                shell(dslFactory.readFileFromWorkspace(getScript()))
                Steps.proxiedGradle(delegate, gradleTasks)
            }
            publishers {
                chucknorris()
            }
        }
    }

    private String getScript() {
        return dirWithScripts+script;
    }

}