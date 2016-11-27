package jobBuilder.Utils

class Scm {

    static void git(context, String repository,String git_branch) {
        context.with {
            git {
                remote {
                    url repository
                    branch git_branch
                }
            }
        }
    }
}