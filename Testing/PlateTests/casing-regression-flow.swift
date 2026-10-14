import Foundation
import Primitives
import Testing

// The original plate casing APIs were relocated to Primitives. Keep their
// observable regressions here until the responsibility is fully moved upstream.
extension PlateTestSuite {
    static let casingRegressionSuite = TestSuite(
        "casing",
        title: "Legacy casing compatibility",
        tags: ["plate", "casing", "legacy"]
    ) {
        Test("basic conversion and dot delimiters") {
            try Expect.equal(Case.convert("My File 42", to: .snake), "my_file_42")
            try Expect.equal(Case.convert("My File 42", to: .camel), "myFile42")
            try Expect.equal(Case.convert("My File 42", to: .pascal), "MyFile42")
            try Expect.equal(Case.convert("My.File 42", to: .snake), "my_file_42")
            try Expect.equal(Case.convert("My.File 42", to: .camel), "myFile42")
            try Expect.equal(Case.convert("My.File 42", to: .pascal), "MyFile42")
        }

        Test("acronyms and digit boundaries") {
            try Expect.equal(Case.convert("URLToID", to: .snake), "url_to_id")
            try Expect.equal(Case.convert("URLToID", to: .camel), "urlToId")
            try Expect.equal(Case.convert("File2HTML", to: .snake), "file_2_html")
            try Expect.equal(Case.convert("File2HTML", to: .camel), "file2Html")
        }

        Test("configured separator sets") {
            try Expect.equal(Case.convert("My.File 42", to: .snake, separators: .commonNoDot), "my.file_42")
            try Expect.equal(Case.convert("A.B C", to: .snake, separators: .space), "a.b_c")
            try Expect.equal(Case.convert("Alpha·Beta Gamma", to: .snake, separators: Separators(" ·")), "alpha_beta_gamma")
            try Expect.equal(Separators.common.contains("."), true)
            try Expect.equal(Separators.commonNoDot.contains("."), false)
        }

        Test("JSON snake casing round trip") {
            struct Demo: Codable, Equatable {
                let firstName: String
                let postalCode: String
            }
            let value = Demo(firstName: "Ada", postalCode: "1011AB")
            let data = try JSONEncoder.casing.snake().encode(value)
            let object = try JSONSerialization.jsonObject(with: data)
            guard let fields = object as? [String: String] else {
                throw CasingTestError.invalidJSONObject
            }
            try Expect.equal(fields["first_name"], "Ada")
            try Expect.equal(fields["postal_code"], "1011AB")
            let decoded = try JSONDecoder.casing.camel().decode(Demo.self, from: data)
            try Expect.equal(decoded, value)
        }
    }
}

private enum CasingTestError: Error { case invalidJSONObject }
