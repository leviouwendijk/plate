import Foundation
import SwiftUI
import Contacts

public struct ContactsListView: View {
    @ObservedObject public var viewModel: ContactsListViewModel
    public let maxListHeight: CGFloat
    public let onSelect: (CNContact) throws -> Void
    public let onDeselect: () -> Void
    public let autoScrollToTop: Bool

    public init(
        viewModel: ContactsListViewModel,
        maxListHeight: CGFloat = 200,
        onSelect: @escaping (CNContact) throws -> Void,
        onDeselect: @escaping () -> Void = {},
        autoScrollToTop: Bool = true
    ) {
        self.viewModel = viewModel
        self.maxListHeight = maxListHeight
        self.onSelect = onSelect
        self.onDeselect = onDeselect
        self.autoScrollToTop = autoScrollToTop
    }

    @State private var showWarning: Bool = false

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            FuzzySearchField(
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
                ZStack {
                    VStack {
                        ScrollViewReader { proxy in
                            List(viewModel.filteredContacts, id: \.identifier) { contact in
                                let isSelected = (viewModel.selectedContactId == contact.identifier)

                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        if viewModel.selectedContactId == contact.identifier {
                                            viewModel.selectedContactId = nil
                                            onDeselect()
                                            withAnimation {
                                                showWarning = false
                                            }
                                        } else {
                                            viewModel.selectedContactId = contact.identifier

                                            if showWarning {
                                                withAnimation {
                                                    showWarning = false
                                                }
                                            }

                                            do {
                                                try onSelect(contact)
                                            } catch {
                                                print("onSelect action error:", error)

                                                withAnimation {
                                                    showWarning = true
                                                }
                                                
                                                // DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                                //     withAnimation { 
                                                //         showWarning = false 
                                                //     }
                                                // }
                                            }
                                        }
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

                            // auto-scroll
                            .onChange(of: viewModel.searchQuery) { _ in
                                guard autoScrollToTop,
                                      let firstID = viewModel.filteredContacts.first?.identifier
                                else { return }
                                withAnimation(.linear(duration: 0.05)) {
                                    proxy.scrollTo(firstID, anchor: .top)
                                }
                            }
                        }

                        if showWarning {
                            NotificationBanner(
                                type: .warning,
                                message: "Cannot extract client and dog names"
                            )
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .zIndex(1)
                        }
                    }
                    .opacity(viewModel.isFuzzyFiltering ? 0 : 1)

                    // if viewModel.isFuzzyFiltering {
                    //     // Color(NSColor.windowBackgroundColor)
                    //     // .opacity(0.95)
                    //     // // .edgesIgnoringSafeArea(.all)
                    //     // .zIndex(0)

                    //     Text("“\(viewModel.searchQuery)”…")
                    //     .font(.title2)
                    //     .foregroundColor(Color.blue)
                    //     .padding(.vertical, 6)
                    //     .padding(.horizontal)
                    //     .cornerRadius(6)
                    //     .padding(.horizontal)
                    //     .zIndex(1)
                    //     .background(
                    //         RoundedRectangle(cornerRadius: 6)
                    //         .fill(Color(NSColor.windowBackgroundColor))
                    //     )
                    // }

                    .overlay(
                        Group {
                            if viewModel.isFuzzyFiltering {
                                Color(NSColor.windowBackgroundColor)
                                .opacity(0.9)
                                .cornerRadius(6)
                            }
                        }
                    )

                    .overlay(
                        Group {
                            if !(viewModel.searchQuery.isEmpty) && viewModel.isFuzzyFiltering {
                                Text("“\(viewModel.searchQuery)”…")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .padding(.vertical, 6)
                                .padding(.horizontal)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(NSColor.windowBackgroundColor))
                                )
                                .zIndex(1)
                            } else if !(viewModel.searchQuery.isEmpty) && !(viewModel.isFuzzyFiltering) && viewModel.filteredContacts.isEmpty {
                                VStack {
                                    HStack {
                                        Text("No results for")
                                        .font(.title2)
                                        .foregroundColor(Color.secondary)
                                        .padding(.vertical, 6)
                                        // .padding(.horizontal)
                                        // .padding(.leading)

                                        Text("“\(viewModel.searchQuery)”")
                                        .font(.title2)
                                        .foregroundColor(Color.secondary)
                                        .padding(.vertical, 6)
                                        // .padding(.horizontal)
                                        // .padding(.trailing)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                            .fill(Color(NSColor.windowBackgroundColor))
                                        )
                                    }
                                    .padding(.horizontal)

                                    Text("Adjust your query or loosen the strictness level")
                                    .font(.caption)
                                    .foregroundColor(Color.secondary)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal)
                                }
                            }
                        }
                    )
                }
                .animation(.easeInOut(duration: 0.35), value: viewModel.isFuzzyFiltering)
            }
        }
    }
}
