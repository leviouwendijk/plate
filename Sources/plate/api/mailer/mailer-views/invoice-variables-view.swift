import Foundation
import SwiftUI
import Combine

public struct MailerAPIInvoiceVariablesView: View {
    @ObservedObject public var vm: MailerAPIInvoiceVariablesViewModel

    public init(vm: MailerAPIInvoiceVariablesViewModel) {
        self.vm = vm
    }

    public var body: some View {
        Form {
            Section("Client & Contact") {
                StandardTextField("Client Name", text: $vm.clientName, placeholder: "Acme Corp")
                StandardTextField("Email",       text: $vm.email,      placeholder: "you@company.com")
            }

            Section("Invoice Details") {
                StandardTextField("Invoice ID",      text: $vm.invoiceId,   placeholder: "e.g. 12345")
                StandardTextField("Due Date",        text: $vm.dueDate,     placeholder: "YYYY-MM-DD")
                StandardTextField("Product Line",    text: $vm.productLine, placeholder: "Service name")
            }

            Section("Amounts & VAT") {
                StandardTextField("Amount",         text: $vm.amount,        placeholder: "e.g. 100.00")
                StandardTextField("VAT %",          text: $vm.vatPercentage, placeholder: "e.g. 21")
                StandardTextField("VAT Amount",     text: $vm.vatAmount,     placeholder: "e.g. 21.00")
                StandardTextField("Total",          text: $vm.total,         placeholder: "e.g. 121.00")
            }

            Section("Terms") {
                StandardTextField("Terms Total",   text: $vm.termsTotal,   placeholder: "e.g. 30 days")
                StandardTextField("Terms Current", text: $vm.termsCurrent, placeholder: "e.g. 0 days past")
            }
        }
        .navigationTitle("Invoice Payload")
    }
}
