// @preconcurrency
import SwiftUI
import Contacts
import Combine

@MainActor
public class ContactsListViewModel: ObservableObject {
    @Published public var contacts: [CNContact] = []
    @Published public var searchQuery: String = ""
    @Published public var isLoading = false
    @Published public var errorMessage: String?

    public var filteredContacts: [CNContact] {
        contacts.filteredClientContacts(matching: searchQuery.normalizedForClientDogSearch)
    }

    public init() {
        Task { await loadAllContacts() }
    }

    func loadAllContacts() async {
        isLoading = true
        errorMessage = nil
        do {
            let fetched = try await loadContacts()
            contacts = fetched
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
