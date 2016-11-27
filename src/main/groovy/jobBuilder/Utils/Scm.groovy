package jobBuilder.Utils

class Scm {

    static void git(context, String repository,String gitBranch) {
        context.with {
            git {
                remote {
                    url repository
                    branch gitBranch
                }
            }
        }
    }
}