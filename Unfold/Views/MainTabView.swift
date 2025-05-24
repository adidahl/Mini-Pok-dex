import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Random Pokemon Tab
            RandomPokemonView()
                .tabItem {
                    Label("Random", systemImage: "dice")
                }
                .tag(0)
            
            // Search Tab
            SearchPokemonView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(1)
            
            // Favorites Tab
            BookmarkedPokemonView()
                .tabItem {
                    Label("Favorites", systemImage: "bookmark")
                }
                .tag(2)
        }
        .accentColor(.blue)
        .onAppear {
            // Set the appearance of the tab bar
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            UITabBar.appearance().standardAppearance = appearance
            
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}

// Preview
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
} 