import SwiftUI

public struct FuzzySearchFieldView: View {
    @Binding public var searchQuery: String
    @Binding public var searchStrictness: SearchStrictness
    public let title: String

    public init(
        title: String? = nil,
        searchQuery: Binding<String>,
        searchStrictness: Binding<SearchStrictness>
    ) {
        self._searchQuery = searchQuery
        self._searchStrictness = searchStrictness
        self.title = title ?? "Search"
    }

    public var body: some View {
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
        .padding(.horizontal)
    }
}
