import SwiftUI

struct ErrorView: View {
    let error: Error
    let retryAction: (() -> Void)?
    
    init(error: Error, retryAction: (() -> Void)? = nil) {
        self.error = error
        self.retryAction = retryAction
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Sad Pikachu or error icon
            Image(systemName: "exclamationmark.triangle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                .foregroundColor(.orange)
            
            Text("Oops! Something went wrong")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(errorMessage)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let retryAction = retryAction {
                Button(action: retryAction) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Try Again")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.top, 10)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
    
    private var errorMessage: String {
        if let networkError = error as? NetworkError {
            return networkError.localizedDescription
        } else {
            return error.localizedDescription
        }
    }
}

struct KidFriendlyErrorView: View {
    let message: String
    let retryAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 24) {
            // Use a fun image
            Image(systemName: "questionmark.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 70, height: 70)
                .foregroundColor(.orange)
                .padding(.bottom, 10)
            
            Text("Hmm, we couldn't find that Pokémon!")
                .font(.title3)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let retryAction = retryAction {
                Button(action: retryAction) {
                    Text("Let's Try Again!")
                        .font(.headline)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue)
                        )
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 5)
            }
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding()
    }
}

struct NetworkErrorView: View {
    let error: NetworkError
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "wifi.slash")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                .foregroundColor(.red)
            
            Text("Connection Problem")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(errorMessage)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: retryAction) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Refresh")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.top, 10)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
    
    private var errorMessage: String {
        switch error {
        case .invalidURL:
            return "There was a problem with the request. Please try again later."
        case .noData:
            return "We couldn't get any data from the server. Please check your connection and try again."
        case .decodingError:
            return "We had trouble understanding the response from the server. Please try again."
        case .serverError(let code):
            return "The server responded with an error (code: \(code)). Please try again later."
        case .unknownError(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
}

// Preview provider
struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ErrorView(error: NetworkError.noData) {
                print("Retry tapped")
            }
            .previewDisplayName("Standard Error")
            
            KidFriendlyErrorView(message: "Maybe try searching for a different Pokémon?") {
                print("Kid-friendly retry tapped")
            }
            .previewDisplayName("Kid-Friendly Error")
            
            NetworkErrorView(error: .serverError(statusCode: 404)) {
                print("Network retry tapped")
            }
            .previewDisplayName("Network Error")
        }
    }
} 