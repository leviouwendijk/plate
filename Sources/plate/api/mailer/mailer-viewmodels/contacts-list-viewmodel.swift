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
    @Published public var searchStrictness: SearchStrictness = .strict

    @Published public var selectedContactId: String? = nil

    // public var filteredContacts: [CNContact] {
    //     contacts
    //     .filteredClientContacts(
    //         matching: searchQuery.normalizedForClientDogSearch, 
    //         fuzzyTolerance: searchStrictness.tolerance
    //     )
    // }

    public var filteredContacts: [CNContact] {
        let query  = searchQuery.normalizedForClientDogSearch
        let tokens = query.clientDogTokens

        let matches = contacts.filteredClientContacts(
            matching: query,
            fuzzyTolerance: searchStrictness.tolerance
        )

        return matches.sorted {

        }
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

public enum SearchStrictness: Int, CaseIterable, Identifiable {
    case exact = 0
    case strict = 2
    case loose  = 3

    public var id: Self { self }
    public var title: String {
        switch self {
        case .exact:  return "Exact"
        case .strict: return "Strict"
        case .loose:  return "Loose"
        }
    }

    public var tolerance: Int { rawValue }
}
