import Foundation
import SwiftUI
import Contacts

public struct ContactsListView: View {
    @ObservedObject public var viewModel: ContactsListViewModel
    public let maxListHeight: CGFloat
    public let onSelect: (CNContact) throws -> Void

    public init(
        viewModel: ContactsListViewModel,
        maxListHeight: CGFloat = 200,
        onSelect: @escaping (CNContact) throws -> Void
    ) {
        self.viewModel = viewModel
        self.maxListHeight = maxListHeight
        self.onSelect = onSelect
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Search Contacts", text: $viewModel.searchQuery)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Menu {
                Picker("Match strictness", selection: $viewModel.searchstrictness) {
                    ForEach(SearchStrictness.allCases) { level in
                        Label(level.title, systemImage: {
                            switch level {
                            case .exact:  return "0.circle"
                            case .strict: return "1.circle"
                            case .loose:  return "3.circle"
                            }
                        }())
                        .tag(level)
                    }
                }
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .imageScale(.medium)
                    .padding(.trailing, 8)
            }

            if let msg = viewModel.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text(msg)
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.red)
                .cornerRadius(6)
                .padding(.horizontal)
            }

            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView("Loading…")
                    Spacer()
                }
                .padding()
            } else {
                List(viewModel.filteredContacts, id: \.identifier) { contact in
                    Button {
                        do {
                            try onSelect(contact)
                        } catch {
                            print("Selection error:", error)
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            let tokens = viewModel.searchQuery.clientDogTokens
                            let fullName = "\(contact.givenName) \(contact.familyName)"
                            Text(fullName.highlighted(tokens))
                            
                            if let email = (contact.emailAddresses.first?.value as String?) {
                                Text(email.highlighted(tokens))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .scrollContentBackground(.hidden)
                .frame(maxHeight: maxListHeight)
                .padding(.horizontal)
            }
        }
    }
}
