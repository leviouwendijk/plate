import Foundation

public struct QuotePayload: MailerAPIPayload {
    public typealias Variables = MailerAPIQuoteVariables

    public let route:     MailerAPIRoute     = .quote
    public let endpoint:  MailerAPIEndpoint
    public let content:   MailerAPIRequestContent<Variables>

    public let quotePath: String = MailerAPIRequestDefaults.defaultQuotePath()

    public init(
            endpoint:     MailerAPIEndpoint,
            variables:    MailerAPIQuoteVariables,
            // client:       String,
            // dog:          String,
            customFrom:   MailerAPIEmailFrom? = nil,
            emailsTo:     [String],
            emailsCC:     [String] = [],
            emailsBCC:    [String] = MailerAPIRequestDefaults.defaultBCC(),
            replyTo:      [String] = MailerAPIRequestDefaults.defaultReplyTo(),
            attachments:  [MailerAPIEmailAttachment]? = nil,
            addHeaders:   [String: String] = [:]
    ) throws {
        self.endpoint = endpoint

        // let variables = MailerAPIQuoteVariables(
        //     name:       client,
        //     dog:        dog
        // )

        let template = MailerAPITemplate(
            variables: variables
        )

        var attach = MailerAPIEmailAttachmentsArray(attachments: attachments)

        let quote = try MailerAPIEmailAttachment(path: quotePath)

        if attachments == nil {
            attach.add(quote)
        }

        let from = customFrom ?? MailerAPIRequestDefaults.defaultFrom(for: route)

        let to = MailerAPIEmailTo(
            to:  emailsTo,
            cc:  emailsCC,
            bcc: emailsBCC,
        )

        self.content = MailerAPIRequestContent(
            from:        from,
            to:          to,
            subject:     nil,
            template:    template,
            headers:     addHeaders,
            replyTo:     replyTo,
            attachments: attach
        )
    }
}
