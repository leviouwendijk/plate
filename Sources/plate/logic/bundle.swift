// for getting a Resource from resources bundle quickly without specifying a bunch of things
// just pass a single file string
import Foundation

public func getResource(_ resource: String) -> String {
    let components = resource.split(separator: ".")

    // If no extension is provided, assume it's a directory
    if components.count == 1 {
        return Bundle.main.path(forResource: resource, ofType: nil) ?? ""
    }

    guard components.count == 2 else {
        print("Error: Invalid resource name format. Use 'filename.extension'.")
        return ""
    }

    let filename = String(components[0])
    let filetype = String(components[1])

    // return Bundle.module.path(forResource: filename, ofType: filetype) ?? ""
    return Bundle.main.path(forResource: filename, ofType: filetype) ?? ""
}

public struct SplitResource {
    public let name: String
    public let filetype: String
}

public func splitFile(_ resource: String) -> SplitResource {
    let empty = SplitResource(name: "null", filetype: "null") 

    let components = resource.split(separator: ".")

    guard components.count == 2 else {
        print("Error: Invalid resource name format. Use 'filename.extension'.")
        return empty 
    }

    let filename = String(components[0])
    let filetype = String(components[1])

    return SplitResource(name: filename, filetype: filetype)
}

// // helper for cross-lib importing
// public enum PlateResources {
//     public static var bundle: Bundle {
//         #if SWIFT_PACKAGE
//         return Bundle.module
//         #else
//         return Bundle(for: PlateResources.self)
//         #endif
//     }

//     public static func url(
//         forResource name: String,
//         withExtension ext: String
//     ) -> URL? {
//         return bundle.url(forResource: name, withExtension: ext)
//     }
// }
