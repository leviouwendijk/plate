import SwiftUI

public struct FuzzySearchField: View {
    @Binding public var searchQuery: String
    @Binding public var searchStrictness: SearchStrictness
    public let title: String
    @Binding public var isFiltering: Bool

    public init(
        title: String? = nil,
        searchQuery: Binding<String>,
        searchStrictness: Binding<SearchStrictness>,
        isFiltering: Binding<Bool>
    ) {
        self._searchQuery = searchQuery
        self._searchStrictness = searchStrictness
        self.title = title ?? "Search"
        self._isFiltering = isFiltering
    }

    public var body: some View {
        VStack {
            HStack(spacing: 8) {
                TextField(title, text: $searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                HStack(spacing: 4) {
                    ForEach(SearchStrictness.allCases) { level in
                        Text(level.title)
                            .font(.caption2)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 6)
                            .background(
                                searchStrictness == level
                                    ? Color.accentColor.opacity(0.2)
                                    : Color.secondary.opacity(0.1)
                            )
                            .cornerRadius(4)
                            .onTapGesture {
                                searchStrictness = level
                            }
                    }
                }
            }

            if isFiltering {
                Text("Searching for “\(searchQuery)”…")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
                .transition(.opacity)
            }
        }
        .padding(.horizontal)
    }
}
