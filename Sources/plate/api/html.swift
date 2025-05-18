import Foundation

// setup for converting NSAttributedString -> Template content, etc
// make generic string -> HTML
public struct HTMLDocument {
    public let content: String
    public let placeInBody: Bool

    public init(
        content: String,
        placeInBody: Bool = false
    ) {
        self.content = content
        self.placeInBody = placeInBody
    }

    public static func insertedBody(placing body: String) -> String {
        return """
        <!DOCTYPE html>
        <html>
            <head>
                <meta charset="UTF-8">
            </head>
            <body>

            \(body)

            </body>
        </html>
        """
    }
}
