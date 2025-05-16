import Foundation

public struct AffiliatePayload: MailerAPIPayload {
    public typealias Variables = MailerAPIAffiliateVariables

    public let route:     MailerAPIRoute     = .affiliate
    public let endpoint:  MailerAPIEndpoint
    public let content:   MailerAPIRequestContent<Variables>

    public init(
            endpoint:     MailerAPIEndpoint = .food,
            variables:    MailerAPIAffiliateVariables,
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
