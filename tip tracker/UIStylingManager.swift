import SwiftUI

/// Manages all UI styling and theming for the app
@MainActor
class UIStylingManager: ObservableObject {
    static let shared = UIStylingManager()
    
    private init() {}
    
    // MARK: - Colors
    @Published var primaryColor: Color = Color("PrimaryPurple")
    @Published var secondaryColor: Color = Color("SecondaryPurple")
    @Published var backgroundColor: Color = Color(.systemBackground)
    @Published var cardBackgroundColor: Color = Color(.systemBackground)
    
    // MARK: - Gradients
    @Published var headerGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [primaryColor.opacity(0.9), secondaryColor.opacity(0.8)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Card Styles
    func cardStyle(_ content: some View) -> some View {
        content
            .padding()
            .background(cardBackgroundColor)
            .cornerRadius(12)
            .shadow(color: primaryColor.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Button Styles
    func primaryButtonStyle(_ content: some View) -> some View {
        content
            .padding()
            .frame(maxWidth: .infinity)
            .background(primaryColor)
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(color: primaryColor.opacity(0.3), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Slider Styles
    func sliderStyle(_ slider: some View) -> some View {
        slider
            .accentColor(primaryColor)
            .padding(.horizontal)
    }
    
    // MARK: - Mood Level Colors
    func moodColor(_ value: Int) -> Color {
        switch value {
        case 1...2: return Color.red
        case 3...4: return Color.orange
        case 5: return Color.yellow
        case 6...7: return Color.green
        case 8...10: return Color.green.opacity(0.8)
        default: return Color.gray
        }
    }
    
    // MARK: - Typography
    func titleStyle(_ text: String) -> Text {
        Text(text)
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(primaryColor)
    }
    
    func headerStyle(_ text: String) -> Text {
        Text(text)
            .font(.headline)
            .fontWeight(.semibold)
    }
    
    // MARK: - Spacing
    let sectionSpacing: CGFloat = 20
    let contentPadding: CGFloat = 16
    
    // MARK: - Theme Management
    func applyTheme(_ theme: SettingsView.Theme) {
        switch theme {
        case .system:
            backgroundColor = Color(.systemBackground)
            cardBackgroundColor = Color(.systemBackground)
        case .light:
            backgroundColor = .white
            cardBackgroundColor = .white
        case .dark:
            backgroundColor = Color(.systemBackground)
            cardBackgroundColor = Color(.systemBackground)
        }
    }
}

/// View modifier for applying card style
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color("PrimaryPurple").opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

/// View modifier for applying primary button style
struct PrimaryButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color("PrimaryPurple"))
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(color: Color("PrimaryPurple").opacity(0.3), radius: 5, x: 0, y: 2)
    }
}

/// View modifier for applying slider style
struct SliderStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .accentColor(Color("PrimaryPurple"))
            .padding(.horizontal)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
    
    func primaryButtonStyle() -> some View {
        modifier(PrimaryButtonStyle())
    }
    
    func sliderStyle() -> some View {
        modifier(SliderStyle())
    }
}
