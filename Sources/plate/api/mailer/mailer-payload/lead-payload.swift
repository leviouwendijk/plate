import Foundation

public struct LeadPayload: MailerAPIPayload {
    public typealias Variables = MailerAPILeadVariables

    public let route:     MailerAPIRoute     = .lead
    public let endpoint:  MailerAPIEndpoint
    public let content:   MailerAPIRequestContent<Variables>

    public init(
            endpoint:     MailerAPIEndpoint,
            client:       String,
            dog:          String,
            availability: MailerAPIAvailabilityContent? = nil,
            customFrom:   MailerAPIEmailFrom? = nil,
            emailsTo:     [String],
            emailsCC:     [String] = [],
            emailsBCC:    [String] = MailerAPIRequestDefaults.defaultBCC(),
            replyTo:      [String] = MailerAPIRequestDefaults.defaultReplyTo(),
            attachments:  [MailerAPIEmailAttachment]? = nil,
            addHeaders:   [String: String] = [:]
    ) throws {
        self.endpoint = endpoint

        let vars = MailerAPILeadVariables(
            name:       client,
            dog:        dog,
            time_range: availability?.time_range()
        )

        let template = MailerAPITemplate(
            variables: vars
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
            body:        nil,
            template:    template,
            headers:     addHeaders,
            replyTo:     replyTo,
            attachments: attach
        )
    }
}
