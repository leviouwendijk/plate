// @preconcurrency
import SwiftUI
@preconcurrency import Contacts
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


    @Published public private(set) var filteredContacts: [CNContact] = []

    public init() {
        Task { await loadAllContacts() }
        setupFilterListener()
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


    private var cancellables = Set<AnyCancellable>()

    private func setupFilterListener() {
        Publishers
        .CombineLatest3($contacts, $searchQuery, $searchStrictness)

        // wait 200ms of “quiet” before firing
        .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
        .sink { [weak self] allContacts, query, strictness in
            self?.applyFilter(
                to: allContacts,
                query: query,
                tolerance: strictness.tolerance
            )
        }
        .store(in: &cancellables)
    }

    private func applyFilter(
        to allContacts: [CNContact],
        query: String,
        tolerance: Int
    ) {
        let normalized = query.normalizedForClientDogSearch

        DispatchQueue.global(qos: .userInitiated).async {
            let results = allContacts
            .filteredClientContacts(
                matching: normalized,
                fuzzyTolerance: tolerance
            )

            DispatchQueue.main.async {
                self.filteredContacts = results
            }
        }
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
