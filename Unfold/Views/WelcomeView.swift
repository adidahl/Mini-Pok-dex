import SwiftUI

struct WelcomeView: View {
    @Binding var hasSeenWelcome: Bool
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Content
            ScrollView {
                VStack(spacing: 30) {
                    // Title
                    Text("Welcome to Mini Pokédex")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 60)
                    
                    // App icon or logo
                    Image(systemName: "sparkles")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 160, height: 160)
                        )
                    
                    // App description
                    Text("Discover the world of Pokémon with your kids!")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Features section
                    featuresSection
                    
                    // Get started button
                    Button(action: {
                        // Mark welcome screen as seen and dismiss
                        withAnimation {
                            hasSeenWelcome = true
                        }
                    }) {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                            )
                            .padding(.horizontal, 50)
                    }
                    .padding(.vertical, 20)
                }
                .padding(.bottom, 50)
            }
        }
    }
    
    // Features section
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 30) {
            // For Parents feature
            featureRow(
                iconName: "person.2.fill",
                title: "For Parents",
                description: "Show your kids a new Pokémon every day and learn together! Bookmark your favorites to revisit later."
            )
            
            // For Kids feature
            featureRow(
                iconName: "star.fill",
                title: "For Kids",
                description: "Discover colorful Pokémon with fun facts about their evolutions and abilities!"
            )
            
            // Search feature
            featureRow(
                iconName: "magnifyingglass",
                title: "Easy Search",
                description: "Find any Pokémon by name or number. Even if you misspell, we'll help find what you're looking for!"
            )
            
            // Random feature
            featureRow(
                iconName: "dice",
                title: "Random Discovery",
                description: "Tap to see a random Pokémon each time - it's like a surprise Pokémon of the day!"
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.15))
        )
        .padding(.horizontal)
    }
    
    // Individual feature row
    private func featureRow(iconName: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            // Feature icon
            Image(systemName: iconName)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
            
            // Feature text
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// Extension to handle welcome screen display logic
extension View {
    func withWelcomeScreen() -> some View {
        // Check if user has seen the welcome screen before
        let hasSeenWelcomeKey = "hasSeenWelcome"
        let hasSeenWelcome = UserDefaults.standard.bool(forKey: hasSeenWelcomeKey)
        
        return self.modifier(WelcomeScreenModifier(
            hasSeenWelcome: hasSeenWelcome,
            markAsSeen: {
                UserDefaults.standard.set(true, forKey: hasSeenWelcomeKey)
            }
        ))
    }
}

// Modifier to handle showing the welcome screen
struct WelcomeScreenModifier: ViewModifier {
    @State private var hasSeenWelcome: Bool
    let markAsSeen: () -> Void
    
    init(hasSeenWelcome: Bool, markAsSeen: @escaping () -> Void) {
        self._hasSeenWelcome = State(initialValue: hasSeenWelcome)
        self.markAsSeen = markAsSeen
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .opacity(hasSeenWelcome ? 1 : 0)
            
            if !hasSeenWelcome {
                WelcomeView(hasSeenWelcome: $hasSeenWelcome)
                    .transition(.opacity)
                    .onChange(of: hasSeenWelcome) { oldValue, newValue in
                        if newValue {
                            markAsSeen()
                        }
                    }
            }
        }
    }
}

// Preview
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(hasSeenWelcome: .constant(false))
    }
} 