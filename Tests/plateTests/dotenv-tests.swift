import XCTest
@testable import plate

final class DotEnvTests: XCTestCase {
    
    /// Test loading a valid `.env` file
    func testLoadValidEnvFile() throws {
        let testEnvPath = "/tmp/test.env"
        
        let testContent = """
        TEST_KEY=HelloWorld
        API_SECRET=supersecret
        """
        
        try testContent.write(toFile: testEnvPath, atomically: true, encoding: .utf8)
        
        let env = DotEnv(path: testEnvPath)
        try env.load()
        
        XCTAssertEqual(String(cString: getenv("TEST_KEY")!), "HelloWorld")
        XCTAssertEqual(String(cString: getenv("API_SECRET")!), "supersecret")
    }
    
    /// Test behavior when `.env` file does not exist
    func testLoadMissingEnvFile() {
        let env = DotEnv(path: "/tmp/missing.env")

        XCTAssertThrowsError(try env.load(), "Expected to throw an error when file is missing") { error in
            XCTAssertTrue(error is NSError)
        }
    }

    /// Test ignoring comments and empty lines
    func testIgnoreCommentsAndEmptyLines() throws {
        let testEnvPath = "/tmp/commented.env"
        
        let testContent = """
        # This is a comment
        ENV_VAR=hello
        
        # Another comment
        API_KEY=abcdef
        
        """
        
        try testContent.write(toFile: testEnvPath, atomically: true, encoding: .utf8)
        
        let env = DotEnv(path: testEnvPath)
        try env.load()
        
        XCTAssertEqual(String(cString: getenv("ENV_VAR")!), "hello")
        XCTAssertEqual(String(cString: getenv("API_KEY")!), "abcdef")
    }

    /// Test directory traversal
    func testDirectoryTraversal() throws {
        let testEnvPath = "/tmp/test/.env"
        
        let testContent = """
        TRAVERSAL_KEY=found_me
        """
        
        let testDirectory = "/tmp/test/"
        try FileManager.default.createDirectory(atPath: testDirectory, withIntermediateDirectories: true, attributes: nil)
        try testContent.write(toFile: testEnvPath, atomically: true, encoding: .utf8)
        
        let env = DotEnv(traverse: 1) // Move up one directory
        try env.load()
        
        XCTAssertEqual(String(cString: getenv("TRAVERSAL_KEY")!), "found_me")
    }
}
