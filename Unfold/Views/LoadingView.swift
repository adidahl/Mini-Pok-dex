import SwiftUI

struct LoadingView: View {
    var message: String = "Loading..."
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(1.5)
            
            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.top, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

struct PokemonLoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            // Custom loading animation with Pokeball
            PokeballLoadingView()
                .frame(width: 80, height: 80)
            
            Text("Catching Pokémon...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

struct PokeballLoadingView: View {
    @State private var isRotating = false
    
    var body: some View {
        ZStack {
            // Pokeball top half (red)
            Circle()
                .fill(Color.red)
                .frame(width: 70, height: 70)
                .offset(y: -17.5)
                .clipShape(
                    Rectangle()
                        .offset(y: -17.5)
                )
            
            // Pokeball bottom half (white)
            Circle()
                .fill(Color.white)
                .frame(width: 70, height: 70)
                .offset(y: 17.5)
                .clipShape(
                    Rectangle()
                        .offset(y: 17.5)
                )
            
            // Pokeball middle line
            Rectangle()
                .fill(Color.black)
                .frame(width: 70, height: 10)
            
            // Pokeball center button
            Circle()
                .fill(Color.white)
                .frame(width: 20, height: 20)
                .overlay(
                    Circle()
                        .stroke(Color.black, lineWidth: 4)
                )
        }
        .rotationEffect(.degrees(isRotating ? 360 : 0))
        .animation(
            Animation.linear(duration: 1)
                .repeatForever(autoreverses: false),
            value: isRotating
        )
        .onAppear {
            isRotating = true
        }
    }
}

// Preview provider
struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoadingView()
                .previewDisplayName("Basic Loading")
            
            PokemonLoadingView()
                .previewDisplayName("Pokemon Loading")
            
            PokeballLoadingView()
                .frame(width: 100, height: 100)
                .previewDisplayName("Pokeball Animation")
                .previewLayout(.sizeThatFits)
        }
    }
} 