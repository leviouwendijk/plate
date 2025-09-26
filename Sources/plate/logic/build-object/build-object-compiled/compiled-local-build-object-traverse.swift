import Foundation

extension CompiledLocalBuildObject {
    public static func traverseForCompiledObjectPkl(
        from startURL: URL = Bundle.main.bundleURL,
        maxDepth: Int = 5,
        compiledFile: String = "compiled.pkl"
    ) throws -> URL {
        try traversingSearch(from: startURL, maxDepth: maxDepth, searching: compiledFile)
    }
}
