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
        onSelect: @escaping (CNContact) -> Void
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
                        onSelect(contact)
                    } label: {
                        HStack {
                            Text("\(contact.givenName) \(contact.familyName)")
                            Spacer()
                            Text(contact.emailAddresses
                                    .first?.value as String? ?? "")
                                .foregroundColor(.gray)
                        }
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
