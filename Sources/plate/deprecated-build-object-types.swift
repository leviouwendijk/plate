// Intentionally empty migration markers. The implementations now live in Executable.
// These are NOT aliases and do not forward values or behavior.

@available(*, deprecated, message: "Moved to Executable.BuildObjectConfiguration; import Executable directly")
public enum BuildObjectConfiguration {
    @available(*, deprecated, message: "Moved to Executable.BuildObjectConfiguration.LegacyObject")
    public enum LegacyObject {}
}

@available(*, deprecated, message: "Moved to Executable.CompiledLocalBuildObject; import Executable directly")
public enum CompiledLocalBuildObject {}

@available(*, deprecated, message: "Moved to Executable.ProjectVersions; import Executable directly")
public enum ProjectVersions {}

@available(*, deprecated, message: "Moved to Executable.CompileInstructionDefaults; import Executable directly")
public enum CompileInstructionDefaults {}

@available(*, deprecated, message: "Moved to Executable.ExecutableObjectType; import Executable directly")
public enum ExecutableObjectType {}

@available(*, deprecated, message: "Moved to Executable.BuildObjectDetails; import Executable directly")
public enum BuildObjectDetails {}

@available(*, deprecated, message: "Moved to Executable.BuildObjectList; import Executable directly")
public enum BuildObjectList {}

@available(*, deprecated, message: "Moved to Executable.BuildSpecification; import Executable directly")
public enum BuildSpecification {}

@available(*, deprecated, message: "Moved to Executable.PklParser; prefer Executable.BuildObjectConfiguration.parse(_:)")
public enum PklParser {}

@available(*, deprecated, message: "Moved to Executable.PklParserError; import Executable directly")
public enum PklParserError: Error {}
