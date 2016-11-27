package jobBuilder.Utils

class Steps {

    static void proxiedGradle(context, String gradleTasks,String gradleSwitches = null) {
        context.with {
            gradle {
                useWrapper true
                tasks gradleTasks
                switches gradleSwitches?.stripIndent()?.trim()
            }
        }
    }
}
