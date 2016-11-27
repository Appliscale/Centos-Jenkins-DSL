package jobBuilder.Utils

class Param {

    static Closure requiredString(
        String _name,
        String _defaultValue=null,
        String _regex="",
        String _failedValidationMessage="You must set this!",
        String _description=null) {
            return {
                it / 'properties' / 'hudson.model.ParametersDefinitionProperty' / parameterDefinitions << 'hudson.plugins.validating__string__parameter.ValidatingStringParameterDefinition' {
                    name(_name)
                    defaultValue(_defaultValue)
                    regex(_regex)
                    failedValidationMessage(_failedValidationMessage)
                    description(_description?.stripIndent()?.trim())
                }
            }
    }

}