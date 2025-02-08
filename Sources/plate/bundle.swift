// for getting a Resource from resources bundle quickly without specifying a bunch of things
// just pass a single file string
import Foundation

func getResource(_ resource: String) -> String {
    let components = resource.split(separator: ".")

    guard components.count == 2 else {
        print("Error: Invalid resource name format. Use 'filename.extension'.")
        return ""
    }

    let filename = String(components[0])
    let filetype = String(components[1])

    // return Bundle.module.path(forResource: filename, ofType: filetype) ?? ""
    return Bundle.main.path(forResource: filename, ofType: filetype) ?? ""
}
