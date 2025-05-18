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
                StandardTextField("Client Name", text: $viewModel.clientName, placeholder: "Acme Corp")
                StandardTextField("Email",       text: $viewModel.email,      placeholder: "you@company.com")
            }

            Section("Invoice Details") {
                StandardTextField("Invoice ID",      text: $viewModel.invoiceId,   placeholder: "e.g. 12345")
                StandardTextField("Due Date",        text: $viewModel.dueDate,     placeholder: "YYYY-MM-DD")
                StandardTextField("Product Line",    text: $viewModel.productLine, placeholder: "Service name")
            }

            Section("Amounts & VAT") {
                StandardTextField("Amount",         text: $viewModel.amount,        placeholder: "e.g. 100.00")
                StandardTextField("VAT %",          text: $viewModel.vatPercentage, placeholder: "e.g. 21")
                StandardTextField("VAT Amount",     text: $viewModel.vatAmount,     placeholder: "e.g. 21.00")
                StandardTextField("Total",          text: $viewModel.total,         placeholder: "e.g. 121.00")
            }

            Section("Terms") {
                StandardTextField("Terms Total",   text: $viewModel.termsTotal,   placeholder: "e.g. 30 days")
                StandardTextField("Terms Current", text: $viewModel.termsCurrent, placeholder: "e.g. 0 days past")
            }
        }
        .navigationTitle("Invoice Payload")
    }
}
