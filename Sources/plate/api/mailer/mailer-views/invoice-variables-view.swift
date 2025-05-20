import Foundation
import SwiftUI
import Combine

public struct MailerAPIInvoiceVariablesView: View {
    @ObservedObject public var viewModel: MailerAPIInvoiceVariablesViewModel

    public init(viewModel: MailerAPIInvoiceVariablesViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Form {
            Section("Client & Contact") {
                StandardTextField("Client Name", text: $viewModel.invoiceVariables.client_name, placeholder: "Acme Corp")
                StandardTextField("Email",       text: $viewModel.invoiceVariables.email,      placeholder: "you@company.com")
            }

            Section("Invoice Details") {
                StandardTextField("Invoice ID",      text: $viewModel.invoiceVariables.invoice_id,   placeholder: "e.g. 12345")
                StandardTextField("Due Date",        text: $viewModel.invoiceVariables.due_date,     placeholder: "YYYY-MM-DD")
                StandardTextField("Product Line",    text: $viewModel.invoiceVariables.product_line, placeholder: "Service name")
            }

            Section("Amounts & VAT") {
                StandardTextField("Amount",         text: $viewModel.invoiceVariables.amount,        placeholder: "e.g. 100.00")
                StandardTextField("VAT %",          text: $viewModel.invoiceVariables.vat_percentage, placeholder: "e.g. 21")
                StandardTextField("VAT Amount",     text: $viewModel.invoiceVariables.vat_amount,     placeholder: "e.g. 21.00")
                StandardTextField("Total",          text: $viewModel.invoiceVariables.total,         placeholder: "e.g. 121.00")
            }

            Section("Terms") {
                StandardTextField("Terms Total",   text: $viewModel.invoiceVariables.terms_total,   placeholder: "e.g. 30 days")
                StandardTextField("Terms Current", text: $viewModel.invoiceVariables.terms_current, placeholder: "e.g. 0 days past")
            }
        }
        .navigationTitle("Invoice Payload")
    }
}
