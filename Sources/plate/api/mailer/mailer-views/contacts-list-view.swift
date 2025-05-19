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
            FuzzySearchFieldView(
                title: "Search contacts",
                searchQuery: $viewModel.searchQuery,
                searchStrictness:  $viewModel.searchStrictness
            )

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
                    let isSelected = (viewModel.selectedContactId == contact.identifier)

                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if viewModel.selectedContactId == contact.identifier {
                                viewModel.selectedContactId = nil
                            } else {
                                viewModel.selectedContactId = contact.identifier
                            }
                        }

                        do {
                            try onSelect(contact)
                        } catch {
                            print("Selection error:", error)
                        }
                    } label: {
                        HStack {
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

                            Spacer()
                        }
                        // .padding(.vertical, 4)

                        .frame(maxWidth: .infinity, alignment: .leading)

                        .padding(12)
                        .background(isSelected
                            ? Color.blue.opacity(0.3)
                            : Color.clear
                        )
                        .cornerRadius(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                            .stroke(isSelected
                                ? Color.blue
                                : Color.clear,
                                lineWidth: 2
                            )
                        )
                        .contentShape(RoundedRectangle(cornerRadius: 5))

                    }
                    .buttonStyle(PlainButtonStyle())
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
                }
                .scrollContentBackground(.hidden)
                .frame(maxHeight: maxListHeight)
                .padding(.horizontal)
            }
        }
    }
}
