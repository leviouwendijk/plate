import Foundation

public struct ResolutionPayload: MailerAPIPayload {
    public typealias Variables = MailerAPIResolutionVariables

    public let route:     MailerAPIRoute     = .resolution
    public let endpoint:  MailerAPIEndpoint
    public let content:   MailerAPIRequestContent<Variables>

    public init(
            endpoint:     MailerAPIEndpoint,
            variables:    MailerAPIResolutionVariables,
            customFrom:   MailerAPIEmailFrom? = nil,
            emailsTo:     [String],
            emailsCC:     [String] = [],
            emailsBCC:    [String] = MailerAPIRequestDefaults.defaultBCC(),
            replyTo:      [String] = MailerAPIRequestDefaults.defaultReplyTo(),
            attachments:  [MailerAPIEmailAttachment]? = nil,
            addHeaders:   [String: String] = [:]
    ) throws {
        self.endpoint = endpoint

        let template = MailerAPITemplate(
            variables: variables
        )

        let attach = MailerAPIEmailAttachmentsArray(attachments: attachments)

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
