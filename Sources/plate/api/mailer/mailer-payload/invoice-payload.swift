import Foundation

public struct InvoicePayload: MailerAPIPayload {
    public typealias Variables = MailerAPIInvoiceVariables

    public let route:     MailerAPIRoute     = .invoice
    public let endpoint:  MailerAPIEndpoint
    public let content:   MailerAPIRequestContent<Variables>

    public let quotePath: String = MailerAPIRequestDefaults.defaultQuotePath()
    public let invoicePath: String = MailerAPIRequestDefaults.defaultInvoicePath()

    public init(
            endpoint:     MailerAPIEndpoint,
            variables:    MailerAPIInvoiceVariables,
            customFrom:   MailerAPIEmailFrom? = nil,
            emailsTo:     [String],
            emailsCC:     [String] = [],
            emailsBCC:    [String] = MailerAPIRequestDefaults.defaultBCC(),
            replyTo:      [String] = MailerAPIRequestDefaults.defaultReplyTo(),
            attachments:  [MailerAPIEmailAttachment]? = nil,
            addHeaders:   [String: String] = [:],
            includeQuote: Bool = false,
            includeInvoice: Bool = false,
    ) throws {
        self.endpoint = endpoint

        let template = MailerAPITemplate(
            variables: variables
        )

        var attach = MailerAPIEmailAttachmentsArray(attachments: attachments)

        let quote = try MailerAPIEmailAttachment(path: quotePath)
        let invoice = try MailerAPIEmailAttachment(path: invoicePath)

        if includeQuote == true {
            attach.add(quote)
        }

        if includeInvoice == true {
            attach.add(invoice)
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
