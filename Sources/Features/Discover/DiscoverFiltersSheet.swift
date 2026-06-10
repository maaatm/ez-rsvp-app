import SwiftUI

/// The "Find events" filter panel — the web app's sidebar, adapted to a sheet:
/// location autocomplete (geocoding), radius + max-price sliders, sort, category
/// chips, and the Mystery-mode toggle that hides categories on the cards.
struct DiscoverFiltersSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var filters: DiscoverFilters

    @State private var search = AddressSearchService()
    @FocusState private var locationFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Space.xl) {
                    header
                    locationSection
                    radiusSection
                    priceSection
                    sortSection
                    mysteryToggle
                    categorySection
                }
                .padding(Theme.Space.lg)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Find events")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Reset", role: .destructive) { reset() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }.fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onAppear { search.clear() }
    }

    // MARK: Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Filter your mystery").font(.title2.weight(.bold))
            Text("Browse mystery-ready plans and filter by comfort level. Mystery mode hides exact categories on the card.")
                .font(.subheadline).foregroundStyle(.secondary)
        }
    }

    private var locationSection: some View {
        section("Location") {
            HStack(spacing: 8) {
                Image(systemName: "mappin.and.ellipse").foregroundStyle(Theme.violet)
                TextField("Type a U.S. address", text: $filters.locationQuery)
                    .focused($locationFocused)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                    .onChange(of: filters.locationQuery) { _, newValue in
                        if filters.selectedLocation?.label != newValue {
                            filters.selectedLocation = nil
                        }
                        search.search(newValue)
                    }
                if !filters.locationQuery.isEmpty {
                    Button {
                        filters.locationQuery = ""
                        filters.selectedLocation = nil
                        search.clear()
                    } label: {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(14)
            .background(Theme.surfaceSunken, in: RoundedRectangle(cornerRadius: Theme.Radius.sm))

            if !search.suggestions.isEmpty {
                VStack(spacing: 0) {
                    ForEach(search.suggestions) { suggestion in
                        Button { select(suggestion) } label: {
                            HStack {
                                Text(suggestion.label)
                                    .font(.subheadline).foregroundStyle(Theme.ink)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Image(systemName: "arrow.up.left")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 11).padding(.horizontal, 14)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        if suggestion.id != search.suggestions.last?.id { Divider() }
                    }
                }
                .glass(cornerRadius: Theme.Radius.sm)
            }

            statusLine
        }
    }

    @ViewBuilder
    private var statusLine: some View {
        Group {
            if search.isSearching {
                Label("Searching addresses…", systemImage: "magnifyingglass")
            } else if filters.selectedLocation != nil {
                Label("Filtering within \(Int(filters.radius)) mi of this address",
                      systemImage: "checkmark.circle.fill")
            } else {
                Label("Select an address to apply radius filtering", systemImage: "info.circle")
            }
        }
        .font(.caption).foregroundStyle(.secondary)
    }

    private var radiusSection: some View {
        section("Radius") {
            HStack {
                Slider(value: $filters.radius, in: 1...25, step: 1).tint(Theme.fuchsia)
                Text("\(Int(filters.radius)) mi")
                    .font(.subheadline.weight(.bold)).foregroundStyle(Theme.violet)
                    .frame(width: 52, alignment: .trailing)
            }
            if filters.selectedLocation == nil {
                Text("Pick a location above to filter by distance.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private var priceSection: some View {
        section("Max price") {
            HStack {
                Slider(value: $filters.maxPrice, in: 0...150, step: 5).tint(Theme.fuchsia)
                Text("$\(Int(filters.maxPrice))")
                    .font(.subheadline.weight(.bold)).foregroundStyle(Theme.violet)
                    .frame(width: 52, alignment: .trailing)
            }
        }
    }

    private var sortSection: some View {
        section("Sort by") {
            Menu {
                Picker("Sort by", selection: $filters.sort) {
                    ForEach(DiscoverSort.allCases) { Text($0.rawValue).tag($0) }
                }
            } label: {
                HStack {
                    Text(filters.sort.rawValue).foregroundStyle(Theme.ink)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption).foregroundStyle(.secondary)
                }
                .padding(14)
                .background(Theme.surfaceSunken, in: RoundedRectangle(cornerRadius: Theme.Radius.sm))
            }
        }
    }

    private var mysteryToggle: some View {
        Toggle(isOn: $filters.mysteryMode.animation(.easeInOut)) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Mystery mode").font(.headline)
                Text("Hide event categories on cards so browsing stays spontaneous.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .tint(Theme.violet)
    }

    private var categorySection: some View {
        section("Categories") {
            FlowLayout(spacing: 8) {
                ForEach(EventCategory.allCases) { category in
                    InterestChip(title: category.rawValue, symbol: category.symbol,
                                 isSelected: filters.categories.contains(category)) {
                        if filters.categories.contains(category) {
                            filters.categories.remove(category)
                        } else {
                            filters.categories.insert(category)
                        }
                    }
                }
            }
            .disabled(filters.mysteryMode)
            .opacity(filters.mysteryMode ? 0.4 : 1)

            if filters.mysteryMode {
                Text("Turn off Mystery mode to filter by category.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    // MARK: Actions

    private func select(_ suggestion: AddressSuggestion) {
        filters.selectedLocation = suggestion
        filters.locationQuery = suggestion.label
        search.clear()
        locationFocused = false
        Haptics.selection()
    }

    private func reset() {
        filters = DiscoverFilters()
        search.clear()
        locationFocused = false
    }

    private func section<Content: View>(_ title: String, @ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.headline)
            content()
        }
    }
}
