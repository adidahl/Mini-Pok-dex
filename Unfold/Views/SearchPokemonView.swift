import SwiftUI

struct SearchPokemonView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var searchText = ""
    @State private var selectedPokemon: Pokemon?
    
    var body: some View {
        NavigationStack {
            VStack {
                // Search bar
                searchBar
                
                // Results or loading indicator
                Group {
                    if viewModel.isLoading {
                        LoadingView(message: "Searching...")
                    } else if let error = viewModel.error {
                        ErrorView(error: error) {
                            if !searchText.isEmpty {
                                viewModel.searchPokemon(query: searchText)
                            }
                        }
                    } else if !searchText.isEmpty && viewModel.searchResults.isEmpty {
                        noResultsView
                    } else if searchText.isEmpty && viewModel.recentSearches.isEmpty && viewModel.searchResults.isEmpty {
                        emptyStateView
                    } else {
                        resultsListView
                    }
                }
                .animation(.easeInOut, value: viewModel.isLoading)
                .animation(.easeInOut, value: viewModel.searchResults)
            }
            .navigationTitle("Pokémon Search")
            .navigationDestination(for: PokemonListItem.self) { pokemonItem in
                // When a PokemonListItem is selected, load the full Pokemon details
                PokemonDetailLoadingView(pokemonId: pokemonItem.id)
            }
            .navigationDestination(for: Pokemon.self) { pokemon in
                // Create a view model for the detail view
                let detailViewModel = PokemonViewModel()
                detailViewModel.pokemon = pokemon
                detailViewModel.state = .loaded
                
                // Fetch species data
                detailViewModel.fetchPokemonSpecies(id: pokemon.id)
                
                return PokemonDetailView(viewModel: detailViewModel)
            }
        }
        .onAppear {
            // Load popular Pokemon when view appears
            if viewModel.searchResults.isEmpty && searchText.isEmpty {
                viewModel.loadPopularPokemon()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search Pokémon", text: $searchText)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .onChange(of: searchText) { newValue in
                    // Debounce search to avoid too many API calls
                    viewModel.debounceSearch(query: newValue)
                }
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    viewModel.clearSearch()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .padding()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(.gray)
            
            Text("Search for a Pokémon")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Enter a Pokémon name or number to start your search!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Show popular searches as examples
            if !viewModel.popularPokemon.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Popular Pokémon")
                        .font(.headline)
                        .padding(.top)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.popularPokemon) { pokemon in
                                popularPokemonButton(pokemon)
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                .padding(.top)
            }
        }
        .padding()
    }
    
    private var noResultsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "questionmark.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(.orange)
            
            Text("No Pokémon Found")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("We couldn't find any Pokémon matching \"\(searchText)\". Try a different name or check your spelling.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Show similar results if available
            if !viewModel.suggestedResults.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Did you mean?")
                        .font(.headline)
                        .padding(.top)
                    
                    ForEach(viewModel.suggestedResults, id: \.id) { pokemon in
                        Button(action: {
                            searchText = pokemon.name
                            viewModel.searchPokemon(query: pokemon.name)
                        }) {
                            Text(pokemon.name.capitalized)
                                .foregroundColor(.blue)
                                .padding(.vertical, 4)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)
            }
        }
        .padding()
    }
    
    private var resultsListView: some View {
        List {
            // If we have search results, show them
            if !viewModel.searchResults.isEmpty {
                Section(header: Text("Search Results")) {
                    ForEach(viewModel.searchResults) { pokemon in
                        searchResultRow(pokemon)
                    }
                }
            }
            
            // Recent searches (if any and we're not currently searching)
            if !viewModel.recentSearches.isEmpty && searchText.isEmpty {
                Section(header: Text("Recent Searches")) {
                    ForEach(viewModel.recentSearches, id: \.id) { pokemon in
                        searchResultRow(pokemon)
                    }
                }
            }
            
            // Popular Pokemon (if we're not currently searching)
            if !viewModel.popularPokemon.isEmpty && searchText.isEmpty {
                Section(header: Text("Popular Pokémon")) {
                    ForEach(viewModel.popularPokemon) { pokemon in
                        searchResultRow(pokemon)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    private func searchResultRow(_ pokemon: PokemonListItem) -> some View {
        NavigationLink(value: pokemon) {
            HStack {
                // Pokemon image (if available)
                AsyncImage(url: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemon.id).png")) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                    } else if phase.error != nil {
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                    } else {
                        ProgressView()
                            .frame(width: 50, height: 50)
                    }
                }
                .background(
                    Circle()
                        .fill(Color(.systemGray6))
                        .frame(width: 60, height: 60)
                )
                
                VStack(alignment: .leading) {
                    Text(pokemon.formattedName)
                        .font(.headline)
                    
                    Text("#\(pokemon.id)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.leading, 8)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
    }
    
    private func popularPokemonButton(_ pokemon: PokemonListItem) -> some View {
        Button(action: {
            searchText = pokemon.name
            viewModel.searchPokemon(query: pokemon.name)
        }) {
            VStack {
                AsyncImage(url: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemon.id).png")) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                    } else if phase.error != nil {
                        Image(systemName: "photo")
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                    } else {
                        ProgressView()
                            .frame(width: 60, height: 60)
                    }
                }
                
                Text(pokemon.formattedName)
                    .font(.caption)
                    .lineLimit(1)
                }
            .frame(width: 80)
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
    }
}

// MARK: - Search View Model

class SearchViewModel: ObservableObject {
    @Published var searchResults: [PokemonListItem] = []
    @Published var suggestedResults: [PokemonListItem] = []
    @Published var recentSearches: [PokemonListItem] = []
    @Published var popularPokemon: [PokemonListItem] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private var searchTask: DispatchWorkItem?
    private var allPokemon: [PokemonListItem] = []
    
    init() {
        loadAllPokemon()
        loadRecentSearches()
    }
    
    // MARK: - Search Functions
    
    func debounceSearch(query: String) {
        // Cancel any previous search task
        searchTask?.cancel()
        
        if query.isEmpty {
            clearSearch()
            return
        }
        
        // Create a new search task with a delay
        let task = DispatchWorkItem { [weak self] in
            self?.searchPokemon(query: query)
        }
        
        searchTask = task
        
        // Execute the task after a delay to debounce rapid typing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: task)
    }
    
    func searchPokemon(query: String) {
        isLoading = true
        error = nil
        searchResults = []
        suggestedResults = []
        
        // First try direct search by name or ID
        NetworkManager.shared.fetchPokemon(idOrName: query.lowercased()) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let pokemon):
                DispatchQueue.main.async {
                    // Direct match found
                    // Create PokemonListItem with url that includes the id
                    let url = "https://pokeapi.co/api/v2/pokemon/\(pokemon.id)/"
                    let item = PokemonListItem(name: pokemon.name, url: url)
                    self.searchResults = [item]
                    self.addToRecentSearches(item)
                    self.isLoading = false
                }
                
            case .failure:
                // No direct match, try fuzzy search
                self.performFuzzySearch(query: query)
            }
        }
    }
    
    private func performFuzzySearch(query: String) {
        // Filter Pokemon with names that are similar to the query
        let results = allPokemon.filter { pokemon in
            let similarity = calculateSimilarity(between: query.lowercased(), and: pokemon.name.lowercased())
            return similarity > 0.6 // 60% similarity threshold
        }.sorted { (a, b) -> Bool in
            let similarityA = calculateSimilarity(between: query.lowercased(), and: a.name.lowercased())
            let similarityB = calculateSimilarity(between: query.lowercased(), and: b.name.lowercased())
            return similarityA > similarityB
        }
        
        DispatchQueue.main.async {
            if results.isEmpty {
                // Try to find some suggestions
                self.suggestedResults = self.allPokemon.filter { pokemon in
                    let similarity = self.calculateSimilarity(between: query.lowercased(), and: pokemon.name.lowercased())
                    return similarity > 0.4 // Lower threshold for suggestions
                }.prefix(5).map { $0 }
            } else {
                self.searchResults = Array(results.prefix(20))
                if let firstResult = results.first {
                    self.addToRecentSearches(firstResult)
                }
            }
            self.isLoading = false
        }
    }
    
    func clearSearch() {
        searchResults = []
        suggestedResults = []
        isLoading = false
        error = nil
    }
    
    // MARK: - Pokemon Details
    
    func loadPokemonDetails(id: Int, completion: @escaping (Pokemon) -> Void) {
        isLoading = true
        
        NetworkManager.shared.fetchPokemon(idOrName: String(id)) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let pokemon):
                    completion(pokemon)
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
    
    // MARK: - Recent Searches
    
    private func loadRecentSearches() {
        if let data = UserDefaults.standard.data(forKey: "recentSearches"),
           let decoded = try? JSONDecoder().decode([PokemonListItem].self, from: data) {
            recentSearches = decoded
        }
    }
    
    private func addToRecentSearches(_ pokemon: PokemonListItem) {
        // Remove if already exists
        recentSearches.removeAll { $0.id == pokemon.id }
        
        // Add to beginning of list
        recentSearches.insert(pokemon, at: 0)
        
        // Keep only the most recent 10
        if recentSearches.count > 10 {
            recentSearches = Array(recentSearches.prefix(10))
        }
        
        // Save to UserDefaults
        if let encoded = try? JSONEncoder().encode(recentSearches) {
            UserDefaults.standard.set(encoded, forKey: "recentSearches")
        }
    }
    
    // MARK: - Popular Pokemon
    
    func loadPopularPokemon() {
        // Hardcoded list of popular Pokemon IDs
        let popularIds = [1, 4, 7, 25, 133, 6, 150, 151, 9, 39]
        
        popularPokemon = allPokemon.filter { popularIds.contains($0.id) }
    }
    
    // MARK: - Utility Functions
    
    private func loadAllPokemon() {
        NetworkManager.shared.fetchPokemonList(limit: 1000, offset: 0) { [weak self] result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self?.allPokemon = response.results
                    self?.loadPopularPokemon()
                }
            case .failure(let error):
                print("Error loading Pokemon list: \(error)")
            }
        }
    }
    
    // Levenshtein distance for fuzzy matching
    private func calculateSimilarity(between s1: String, and s2: String) -> Double {
        let empty = [Int](repeating: 0, count: s2.count)
        var last = [Int](0...s2.count)
        
        for (i, c1) in s1.enumerated() {
            var current = [i + 1] + empty
            for (j, c2) in s2.enumerated() {
                current[j + 1] = c1 == c2 ? last[j] : min(last[j], last[j + 1], current[j]) + 1
            }
            last = current
        }
        
        let distance = Double(last.last ?? 0)
        let maxLength = Double(max(s1.count, s2.count))
        
        // Return similarity as a value between 0 and 1
        return 1.0 - (distance / maxLength)
    }
}

// MARK: - Pokemon Detail Loading View

struct PokemonDetailLoadingView: View {
    let pokemonId: Int
    @StateObject private var viewModel = PokemonViewModel()
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                PokemonLoadingView()
                
            case .loaded:
                if let pokemon = viewModel.pokemon {
                    PokemonDetailView(viewModel: viewModel)
                        .onDisappear {
                            // Update shared view model when returning from detail view
                            DispatchQueue.main.async {
                                SharedPokemonViewModel.shared.loadBookmarkedPokemon()
                            }
                        }
                } else {
                    ErrorView(error: NetworkError.noData) {
                        loadPokemon()
                    }
                }
                
            case .error(let error):
                ErrorView(error: error) {
                    loadPokemon()
                }
                
            case .empty:
                PokemonLoadingView()
            }
        }
        .navigationTitle("Pokémon Details")
        .onAppear {
            if viewModel.state == .empty {
                loadPokemon()
            }
            
            // Copy bookmarks from shared model using async to avoid state updates during view rendering
            DispatchQueue.main.async {
                self.viewModel.bookmarkedPokemon = SharedPokemonViewModel.shared.bookmarkedPokemon
            }
        }
    }
    
    private func loadPokemon() {
        viewModel.fetchPokemon(idOrName: String(pokemonId))
    }
}

// Preview
struct SearchPokemonView_Previews: PreviewProvider {
    static var previews: some View {
        SearchPokemonView()
    }
} 