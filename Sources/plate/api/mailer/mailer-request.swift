import Foundation

public struct MailerAPIRequestDefaults: Encodable {
    public init() {}

    public static func automationsEmail() -> String {
        return environment(MailerAPIEnvironmentKey.automationsEmail.rawValue)
    }

    public static func supportEmail() -> String {
        return environment(MailerAPIEnvironmentKey.replyTo.rawValue)
    }

    public static func defaultQuotePath() -> String {
        return environment(MailerAPIEnvironmentKey.quotePath.rawValue)
    }

    public static func defaultInvoicePath() -> String {
        return environment(MailerAPIEnvironmentKey.invoicePDF.rawValue)
    }

    public static func defaultBaseURL() -> String {
        return environment(MailerAPIEnvironmentKey.apiURL.rawValue)
    }

    public static func defaultBCC() -> [String] {
        let email = automationsEmail()
        return [email]
    }

    public static func defaultReplyTo() -> [String] {
        let email = supportEmail()
        return [email]
    }

    public static func defaultFrom(for route: MailerAPIRoute) -> MailerAPIEmailFrom {
        let from = MailerAPIEmailFrom(
            name:  environment(MailerAPIEnvironmentKey.from.rawValue),
            alias: route.alias(),
            domain: environment(MailerAPIEnvironmentKey.domain.rawValue)
        )
        return from
    }
}

public struct MailerAPIRequestContent<Variables: Encodable>: Encodable {
    public let from:        MailerAPIEmailFrom?
    public let to:          MailerAPIEmailTo?
    public let subject:     String?
    // public let body:        String? // should be in Template vars?
    public let template:    MailerAPITemplate<Variables>?
    public let headers:     [String:String]
    public let replyTo:     [String]?
    public let attachments: MailerAPIEmailAttachmentsArray

    private enum CodingKeys: String, CodingKey {
        case from, to, cc, bcc, replyTo, subject, body, template, headers, attachments
    }

    public init(
        from:        MailerAPIEmailFrom? = nil,
        to:          MailerAPIEmailTo? = nil,
        subject:     String? = nil,
        // body:        String? = nil,
        template:    MailerAPITemplate<Variables>? = nil,
        headers:     [String:String] = [:],
        replyTo:     [String]? = nil,
        attachments: MailerAPIEmailAttachmentsArray
    ) {
        self.from        = from
        self.to          = to
        self.subject     = subject
        // self.body        = body
        self.template    = template
        self.headers     = headers
        self.replyTo     = replyTo
        self.attachments = attachments
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        // Only emit “from” if it’s non‐nil
        try container.encodeIfPresent(from, forKey: .from)

        // Only emit to/cc/bcc if “to” is non‐nil
        if let to = to {
            try container.encode(to.to, forKey: .to)
            try container.encode(to.cc, forKey: .cc)
            try container.encode(to.bcc, forKey: .bcc)
        }

        // Same for replyTo
        try container.encodeIfPresent(replyTo, forKey: .replyTo)

        // The rest can stay encodeIfPresent or encode (for non‐optionals)
        try container.encodeIfPresent(subject,  forKey: .subject)
        // try container.encodeIfPresent(body,     forKey: .body)
        try container.encodeIfPresent(template, forKey: .template)
        try container.encode(headers,            forKey: .headers)
        try container.encode(attachments,       forKey: .attachments)
    }
}

public struct MailerAPITemplate<Variables: Encodable>: Encodable {
    public let category:  String? = nil
    public let file:      String? = nil
    public let variables: Variables
}

// public struct MailerAPITemplate: Encodable {
//     public let category: String
//     public let file: String
//     public let variables: [String: Any]

//     public init(category: String, file: String, variables: [String: Any]) {
//         self.category = category
//         self.file = file
//         self.variables = variables
//     }

//     public func dictionary() -> [String: Any] {
//         return [
//             "category": category,
//             "file": file,
//             "variables": variables
//         ]
//     }
// }

public struct MailerAPIEmailFrom: Encodable {
    public let name: String
    public let alias: String
    public let domain: String

    public init(name: String, alias: String, domain: String) {
        self.name = name
        self.alias = alias
        self.domain = domain
    }

    public func dictionary() -> [String: String] {
        return [
            "name": name,
            "alias": alias,
            "domain": domain
        ]
    } 
}

public struct MailerAPIEmailTo: Encodable {
    public let to: [String]
    public let cc: [String]
    public let bcc: [String]
    
    public func dictionary() -> [String: [String]] {
        return [
            "to": to,
            "cc": cc,
            "bcc": bcc
        ]
    } 
}

public enum MailerAPIEmailAttachmentFileType: String, Encodable {
    case pdf = "pdf"
    case jpg = "jpg"
    case png = "png"
    case txt = "txt"
    case json = "json"
    case unknown = "unknown"
    
    public static func from(extension ext: String) -> MailerAPIEmailAttachmentFileType {
        return MailerAPIEmailAttachmentFileType(rawValue: ext.lowercased()) ?? .unknown
    }
}

public struct MailerAPIEmailAttachment: Encodable {
    public let path: String
    public let type: MailerAPIEmailAttachmentFileType
    public let value: String
    public let name: String

    public init(
        path: String,
        type: MailerAPIEmailAttachmentFileType? = nil,
        name: String? = nil
    ) throws {
        self.path = path
        let fileURL = URL(fileURLWithPath: path)

        self.value = try fileURL.base64()

        let fileExtension = (path as NSString).pathExtension

        self.type = type ?? .from(extension: fileExtension)
        self.name = name ?? fileURL.lastPathComponent
    }

    public func dictionary() -> [String: String] {
        return [
            "type": type.rawValue,
            "value": value,
            "name": name
        ]
    }

    // emit only these
    private enum CodingKeys: String, CodingKey {
        case type, value, name
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type.rawValue, forKey: .type)
        try container.encode(value, forKey: .value)
        try container.encode(name,  forKey: .name)
    }
}

extension URL {
    public func base64() throws -> String {
        try Data(contentsOf: self).base64EncodedString()
    }
}

public struct MailerAPIEmailAttachmentsArray: Encodable {
    private(set) var attachments: [MailerAPIEmailAttachment] = []

    public init() {}

    public init(attachments: [MailerAPIEmailAttachment]? = nil) {
        self.attachments = attachments ?? []
    }

    public mutating func add(_ attachment: MailerAPIEmailAttachment) {
        attachments.append(attachment)
    }

    public mutating func add(contentsOf attachmentsArray: [MailerAPIEmailAttachment]) {
        attachments.append(contentsOf: attachmentsArray)
    }

    public mutating func add(
        from paths: [String],
        type: MailerAPIEmailAttachmentFileType
    ) throws {
        for path in paths {
            let fileName = (path as NSString).lastPathComponent
            let attachment = try MailerAPIEmailAttachment(
                path: path,
                type: type,
                name: fileName
            )
            attachments.append(attachment)
        }
    }

    public init(
        paths: [String],
        type: MailerAPIEmailAttachmentFileType
    ) throws {
        self.init()
        try add(from: paths, type: type)
    }

    public func array() -> [[String: String]] {
        attachments.map { $0.dictionary() }
    }

    // older version reliant on dictionary()
    // public func encode(to encoder: Encoder) throws {
    //     var container = encoder.unkeyedContainer()
    //     for dict in attachments.map({ $0.dictionary() }) {
    //         try container.encode(dict)
    //     }
    // }

    // new version with encodable MailerAPIEmailAttachment struct
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for attachment in attachments {
            try container.encode(attachment)
        }
    }
}

public struct ICSBuilder: Encodable {
    /// Converts a Date to an ICS-compliant UTC timestamp string ("yyyyMMdd'T'HHmmss'Z'").
    public static func dateToICS(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: date)
    }

    /// Returns the current timestamp in ICS "DTSTAMP" format.
    public static func timestamp() -> String {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime]
        let raw = iso.string(from: Date())
        // Strip out hyphens, colons, and fractional seconds
        let cleaned = raw
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: ":", with: "")
            .components(separatedBy: ".").first ?? raw
        return cleaned
    }

    /// Generates a full iCalendar string for a single VEVENT.
    ///
    /// - Parameters:
    ///   - uid: A unique identifier for the event (default: random UUID).
    ///   - start: The event start date (UTC).
    ///   - end: The event end date (UTC).
    ///   - summary: A brief summary or title for the event.
    ///   - description: A longer description, newlines as "\\n".
    ///   - location: A human-readable location string (can include newlines with "\\n").
    ///   - prodId: An optional product identifier string for the calendar (default: your app).
    public static func event(
        uid: String = UUID().uuidString,
        start: Date,
        end: Date,
        summary: String,
        description: String,
        location: String,
        prodId: String
    ) -> String {
        let dtStamp = timestamp()
        let dtStart = dateToICS(start)
        let dtEnd = dateToICS(end)

        return [
            "BEGIN:VCALENDAR",
            "VERSION:2.0",
            "PRODID:\(prodId)",
            "BEGIN:VEVENT",
            "UID:\(uid)",
            "DTSTAMP:\(dtStamp)",
            "DTSTART:\(dtStart)",
            "DTEND:\(dtEnd)",
            "SUMMARY:\(escapeText(summary))",
            "DESCRIPTION:\(escapeText(description))",
            "LOCATION:\(escapeText(location))",
            "END:VEVENT",
            "END:VCALENDAR"
        ]
        .joined(separator: "\r\n")
    }

    /// Escapes commas, semicolons, and newlines for ICS compatibility.
    private static func escapeText(_ text: String) -> String {
        let escaped = text
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: ";", with: "\\;")
            .replacingOccurrences(of: ",", with: "\\,")
            .replacingOccurrences(of: "\n", with: "\\n")
        return escaped
    }
}

