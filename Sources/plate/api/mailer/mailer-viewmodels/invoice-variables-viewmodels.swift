import Foundation
import Combine

@MainActor
public class MailerAPIInvoiceVariablesViewModel: ObservableObject {
    @Published public var clientName    = ""
    @Published public var email         = ""
    @Published public var invoiceId     = ""
    @Published public var dueDate       = ""
    @Published public var productLine   = ""
    @Published public var amount        = ""
    @Published public var vatPercentage = ""
    @Published public var vatAmount     = ""
    @Published public var total         = ""
    @Published public var termsTotal    = ""
    @Published public var termsCurrent  = ""

    private let store: VariableStore
    private var cancellables = Set<AnyCancellable>()

    public init(store: VariableStore = .shared) {
        self.store = store

        // Sync store → VM
        store.$values
            .receive(on: DispatchQueue.main)
            .sink { [weak self] dict in
                guard let self = self else { return }
                self.clientName    = dict["client_name", default: ""]
                self.email         = dict["email",       default: ""]
                self.invoiceId     = dict["invoice_id",  default: ""]
                self.dueDate       = dict["due_date",    default: ""]
                self.productLine   = dict["product_line",default: ""]
                self.amount        = dict["amount",      default: ""]
                self.vatPercentage = dict["vat_percentage", default: ""]
                self.vatAmount     = dict["vat_amount",    default: ""]
                self.total         = dict["total",         default: ""]
                self.termsTotal    = dict["terms_total",   default: ""]
                self.termsCurrent  = dict["terms_current", default: ""]
            }
            .store(in: &cancellables)

        // Sync VM → store
        $clientName
            .sink { [weak store] in store?.values["client_name"] = $0 }
            .store(in: &cancellables)
        $email
            .sink { [weak store] in store?.values["email"] = $0 }
            .store(in: &cancellables)
        $invoiceId
            .sink { [weak store] in store?.values["invoice_id"] = $0 }
            .store(in: &cancellables)
        $dueDate
            .sink { [weak store] in store?.values["due_date"] = $0 }
            .store(in: &cancellables)
        $productLine
            .sink { [weak store] in store?.values["product_line"] = $0 }
            .store(in: &cancellables)
        $amount
            .sink { [weak store] in store?.values["amount"] = $0 }
            .store(in: &cancellables)
        $vatPercentage
            .sink { [weak store] in store?.values["vat_percentage"] = $0 }
            .store(in: &cancellables)
        $vatAmount
            .sink { [weak store] in store?.values["vat_amount"] = $0 }
            .store(in: &cancellables)
        $total
            .sink { [weak store] in store?.values["total"] = $0 }
            .store(in: &cancellables)
        $termsTotal
            .sink { [weak store] in store?.values["terms_total"] = $0 }
            .store(in: &cancellables)
        $termsCurrent
            .sink { [weak store] in store?.values["terms_current"] = $0 }
            .store(in: &cancellables)
    }

    public func variables() -> MailerAPIInvoiceVariables {
        .init(
            clientName:    clientName,
            email:         email,
            invoiceId:     invoiceId,
            dueDate:       dueDate,
            productLine:   productLine,
            amount:        amount,
            vatPercentage: vatPercentage,
            vatAmount:     vatAmount,
            total:         total,
            termsTotal:    termsTotal,
            termsCurrent:  termsCurrent
        )
    }
}

// @MainActor
// public class MailerAPIInvoiceVariablesViewModel: ObservableObject {
//     @StoredVariable(key: "client_name")     public var clientName:   String
//     @StoredVariable(key: "email")           public var email:        String
//     @StoredVariable(key: "invoice_id")      public var invoiceId:    String
//     @StoredVariable(key: "due_date")        public var dueDate:      String
//     @StoredVariable(key: "product_line")    public var productLine:  String
//     @StoredVariable(key: "amount")          public var amount:       String
//     @StoredVariable(key: "vat_percentage")  public var vatPercentage:String
//     @StoredVariable(key: "vat_amount")      public var vatAmount:    String
//     @StoredVariable(key: "total")           public var total:        String
//     @StoredVariable(key: "terms_total")     public var termsTotal:   String
//     @StoredVariable(key: "terms_current")   public var termsCurrent: String

//     private let store: VariableStore

//     /// Require a `VariableStore` so you can inject `.shared` or a test store.
//     public init(store: VariableStore = .shared) {
//         self.store = store

//         _clientName    = StoredVariable(key: "client_name",   store: store)
//         _email         = StoredVariable(key: "email",         store: store)
//         _invoiceId     = StoredVariable(key: "invoice_id",    store: store)
//         _dueDate       = StoredVariable(key: "due_date",      store: store)
//         _productLine   = StoredVariable(key: "product_line",  store: store)
//         _amount        = StoredVariable(key: "amount",        store: store)
//         _vatPercentage = StoredVariable(key: "vat_percentage",store: store)
//         _vatAmount     = StoredVariable(key: "vat_amount",    store: store)
//         _total         = StoredVariable(key: "total",         store: store)
//         _termsTotal    = StoredVariable(key: "terms_total",   store: store)
//         _termsCurrent  = StoredVariable(key: "terms_current", store: store)
//     }

//     public func variables() -> MailerAPIInvoiceVariables {
//         MailerAPIInvoiceVariables(
//             clientName:    clientName,
//             email:         email,
//             invoiceId:     invoiceId,
//             dueDate:       dueDate,
//             productLine:   productLine,
//             amount:        amount,
//             vatPercentage: vatPercentage,
//             vatAmount:     vatAmount,
//             total:         total,
//             termsTotal:    termsTotal,
//             termsCurrent:  termsCurrent
//         )
//     }
// }
