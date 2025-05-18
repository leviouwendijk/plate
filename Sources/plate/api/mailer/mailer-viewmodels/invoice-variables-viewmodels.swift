import Foundation
import Combine

@MainActor
public class MailerAPIInvoiceVariablesViewModel: ObservableObject {
    @StoredVariable(key: "client_name")     public var clientName:   String
    @StoredVariable(key: "email")           public var email:        String
    @StoredVariable(key: "invoice_id")      public var invoiceId:    String
    @StoredVariable(key: "due_date")        public var dueDate:      String
    @StoredVariable(key: "product_line")    public var productLine:  String
    @StoredVariable(key: "amount")          public var amount:       String
    @StoredVariable(key: "vat_percentage")  public var vatPercentage:String
    @StoredVariable(key: "vat_amount")      public var vatAmount:    String
    @StoredVariable(key: "total")           public var total:        String
    @StoredVariable(key: "terms_total")     public var termsTotal:   String
    @StoredVariable(key: "terms_current")   public var termsCurrent: String

    private let store: VariableStore

    /// Require a `VariableStore` so you can inject `.shared` or a test store.
    public init(store: VariableStore = .shared) {
        self.store = store

        _clientName    = StoredVariable(key: "client_name",   store: store)
        _email         = StoredVariable(key: "email",         store: store)
        _invoiceId     = StoredVariable(key: "invoice_id",    store: store)
        _dueDate       = StoredVariable(key: "due_date",      store: store)
        _productLine   = StoredVariable(key: "product_line",  store: store)
        _amount        = StoredVariable(key: "amount",        store: store)
        _vatPercentage = StoredVariable(key: "vat_percentage",store: store)
        _vatAmount     = StoredVariable(key: "vat_amount",    store: store)
        _total         = StoredVariable(key: "total",         store: store)
        _termsTotal    = StoredVariable(key: "terms_total",   store: store)
        _termsCurrent  = StoredVariable(key: "terms_current", store: store)
    }

    public func variables() -> MailerAPIInvoiceVariables {
        MailerAPIInvoiceVariables(
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
