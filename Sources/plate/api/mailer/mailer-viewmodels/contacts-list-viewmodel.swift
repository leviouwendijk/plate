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
    @Published public var isFuzzyFiltering = false

    public init() {
        Task { await loadAllContacts() }
        fuzzyFilterListener()
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

    private func fuzzyFilterListener() {
        Publishers
        .CombineLatest3($contacts, $searchQuery, $searchStrictness)
        .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
        .sink { [weak self] allContacts, query, strictness in
            guard let self = self else { return }

            if !(self.isLoading) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    self.isFuzzyFiltering = true
                }
            }

            self.applyFuzzyFilter(
                to: allContacts,
                query: query,
                tolerance: strictness.tolerance
            )
        }
        .store(in: &cancellables)
    }

    private func applyFuzzyFilter(
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
                withAnimation(.easeInOut(duration: 0.25)) {
                    self.filteredContacts = results
                    self.isFuzzyFiltering = false
                }
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
