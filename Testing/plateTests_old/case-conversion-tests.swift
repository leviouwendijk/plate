import Foundation
import Testing
@testable import plate

@Suite("Case conversion core")
struct CaseConversionTests {

    @Test("Basic conversions with default separators (includes dot)")
    func basicConversions_default() {
        // Spaces & common delimiters split; dot splits by default
        #expect(convertIdentifier("My File 42", to: .snake)   == "my_file_42")
        #expect(convertIdentifier("My File 42", to: .camel)   == "myFile42")
        #expect(convertIdentifier("My File 42", to: .pascal)  == "MyFile42")

        #expect(convertIdentifier("My.File 42", to: .snake)   == "my_file_42")
        #expect(convertIdentifier("My.File 42", to: .camel)   == "myFile42")
        #expect(convertIdentifier("My.File 42", to: .pascal)  == "MyFile42")
    }

    @Test("Dot preserved when excluded from separators")
    func dotPreserved_whenExcluded() {
        let noDot = SeparatorPolicy.commonNoDot
        #expect(convertIdentifier("My.File 42", to: .snake, separators: noDot)  == "my.file_42")
        #expect(convertIdentifier("My.File 42", to: .camel, separators: noDot)  == "my.file42")
        #expect(convertIdentifier("My.File 42", to: .pascal, separators: noDot) == "My.File42")
    }

    @Test("Acronym handling and letter↔digit boundaries")
    func acronyms_and_digits() {
        // "URLToID" → ["URL","To","ID"] → url_to_id / urlToId / UrlToId
        #expect(convertIdentifier("URLToID", to: .snake)  == "url_to_id")
        #expect(convertIdentifier("URLToID", to: .camel)  == "urlToId")
        #expect(convertIdentifier("URLToID", to: .pascal) == "UrlToId")

        // letter↔digit boundaries
        #expect(convertIdentifier("File2HTML", to: .snake)  == "file_2_html")
        #expect(convertIdentifier("File2HTML", to: .camel)  == "file2Html")
        #expect(convertIdentifier("File2HTML", to: .pascal) == "File2Html")

        #expect(convertIdentifier("v2", to: .snake)  == "v_2")
        #expect(convertIdentifier("v2", to: .camel)  == "v2")
        #expect(convertIdentifier("v2", to: .pascal) == "V2")
    }

    @Test("Whitespace-only separators")
    func whitespaceOnlySeparators() {
        let ws = SeparatorPolicy.whitespaceOnly
        // Dot is NOT a separator here
        #expect(convertIdentifier("A.B C", to: .snake,  separators: ws) == "a.b_c")
        #expect(convertIdentifier("A.B C", to: .camel,  separators: ws) == "a.bC")
        #expect(convertIdentifier("A.B C", to: .pascal, separators: ws) == "A.bC")
    }

    @Test("Custom non-ASCII separator (middle dot)")
    func customNonASCIISeparator() {
        // Treat U+00B7 (·) as a separator in addition to space
        let policy = SeparatorPolicy(
            asciiString: " ",
            nonASCII: { $0 == "\u{00B7}" } // middle dot
        )
        #expect(convertIdentifier("Alpha·Beta Gamma", to: .snake, separators: policy)  == "alpha_beta_gamma")
        #expect(convertIdentifier("Alpha·Beta Gamma", to: .camel, separators: policy)  == "alphaBetaGamma")
        #expect(convertIdentifier("Alpha·Beta Gamma", to: .pascal, separators: policy) == "AlphaBetaGamma")
    }

    @Test("Back-compat helpers still behave")
    func backCompatHelpers() {
        #expect(convertToSnakeCase("myHTTPServer42") == "my_http_server_42")
        #expect(convertToCamelCase("my_http_server_42") == "myHttpServer42")
        #expect(convertToPascalCase("my_http_server_42") == "MyHttpServer42")
    }
}

@Suite("Encoders/Decoders & strategies")
struct CaseConversionCodableTests {

    private struct Demo: Codable, QuicklyEncodable, QuicklyDecodable, Equatable {
        // Swift properties in camelCase (typical)
        var myHttpServer42: Int
        var urlId: String
    }

    @Test("JSONEncoder snake keys; JSONDecoder round-trip")
    func snakeEncoder_roundTrip() throws {
        let demo = Demo(myHttpServer42: 7, urlId: "ok")

        // Encode with snake keys
        let enc = JSONEncoder.snakeCaseEncoder()
        let data = try enc.encode(demo)

        // Keys should be snake_case
        let dict: [String: Any] = try #require(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )
        let keys = Set(dict.keys)
        #expect(keys.contains("my_http_server_42"))
        #expect(keys.contains("url_id"))

        // Decode back with snakeCaseDecoder (maps to camel properties)
        let dec = JSONDecoder.snakeCaseDecoder()
        let decoded = try dec.decode(Demo.self, from: data)
        #expect(decoded == demo)
    }

    @Test("PascalCase encoder produces PascalCase keys")
    func pascalEncoder_keys() throws {
        let demo = Demo(myHttpServer42: 1, urlId: "x")
        let enc = JSONEncoder.pascalCaseEncoder()
        let data = try enc.encode(demo)
        let dict: [String: Any] = try #require(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )
        let keys = Set(dict.keys)
        #expect(keys.contains("MyHttpServer42"))
        #expect(keys.contains("UrlId"))
    }

    @Test("CustomStrategies quickEncode/quickDecode default to camel↔snake")
    func quickHelpers_default() {
        struct S: Codable, QuicklyEncodable, QuicklyDecodable, Equatable {
            var firstName: String
            var postalCode: String
        }
        let s = S(firstName: "Ada", postalCode: "1011AB")
        let json = s.quickEncode()!
        let data = try! #require(json.data(using: .utf8))
        let dict = try! #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect(dict["first_name"] as? String == "Ada")
        #expect(dict["postal_code"] as? String == "1011AB")

        let round = S.quickDecode(from: json)!
        #expect(round == s)
    }

    @Test("Encoders/Decoders honor custom separators")
    func encodersHonorSeparators() throws {
        struct F: Codable, Equatable {
            var fileName: String
        }
        let f = F(fileName: "Doc")
        // Preserve dot in keys by excluding it
        let enc = JSONEncoder.encoder(keyCase: .snake, separators: .commonNoDot)
        let d = try enc.encode(f)
        let dict = try JSONSerialization.jsonObject(with: d) as? [String: Any]
        // No dot present in property so this just sanity checks we can pass custom policy;
        // Now force a dot via a coding key wrapper by hand:
        #expect(dict?.keys.contains("file_name") == true)

        // Decode using a decoder that ALSO excludes dot (API symmetry)
        let dec = JSONDecoder.decoder(from: .snake, to: .camel, separators: .commonNoDot)
        let back = try dec.decode(F.self, from: d)
        #expect(back == f)
    }
}

@Suite("SeparatorPolicy presets & membership")
struct SeparatorPolicyTests {

    @Test("Preset membership")
    func presetMembership() {
        let withDot = SeparatorPolicy.commonWithDot
        let noDot   = SeparatorPolicy.commonNoDot
        let ws      = SeparatorPolicy.whitespaceOnly

        #expect(withDot.contains("."))
        #expect(!noDot.contains("."))
        #expect(ws.contains(" "))
        #expect(!ws.contains("_"))
    }

    @Test("Init ergonomics remain available")
    func initOverloads() {
        // these should compile & behave equivalently
        _ = SeparatorPolicy(asciiString: " _-./+:,")
        _ = SeparatorPolicy(chars: Array(" _-/+:,"))
        _ = SeparatorPolicy(scalars: " ,".unicodeScalars)
    }
}
