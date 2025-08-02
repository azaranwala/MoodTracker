import SwiftUI

/// App Store metadata and assets
struct AppStoreAssets {
    // MARK: - App Icon
    static let appIcon: String = "AppIcon"
    
    // MARK: - App Store Screenshots
    static let screenshots: [Screenshot] = [
        Screenshot(
            title: "Track Your Mood",
            description: "Easily rate your mood with our intuitive slider and emoji system."
        ),
        Screenshot(
            title: "Daily Analytics",
            description: "View your mood trends over time with our interactive analytics dashboard."
        ),
        Screenshot(
            title: "History & Search",
            description: "Keep track of your mood history and search through past entries with ease."
        ),
        Screenshot(
            title: "Custom Reminders",
            description: "Set custom mood reminders to help you stay consistent with tracking."
        ),
        Screenshot(
            title: "Privacy First",
            description: "Your mood data stays private and secure on your device."
        )
    ]
    
    // MARK: - App Store Metadata
    static let metadata: Metadata = Metadata(
        name: "MoodTracker",
        subtitle: "Track Your Mood, Understand Your Emotions",
        description: "MoodTracker is a simple yet powerful tool to help you track your daily mood. With our intuitive interface, you can easily rate your mood on a scale of 1-10 and add notes to capture your thoughts. The analytics dashboard provides valuable insights into your mood patterns, helping you understand your emotional well-being better. Perfect for journaling, mental health tracking, or just keeping a record of your daily mood.",
        keywords: ["mood", "tracker", "journal", "emotions", "mental health", "daily tracking", "analytics", "well-being"],
        privacyPolicyURL: "https://moodtracker.com/privacy",
        supportURL: "https://moodtracker.com/support"
    )
}

/// Screenshot metadata
struct Screenshot {
    let title: String
    let description: String
}

/// App Store metadata
struct Metadata {
    let name: String
    let subtitle: String
    let description: String
    let keywords: [String]
    let privacyPolicyURL: String
    let supportURL: String
}

/// App Icon sizes
enum AppIconSize: String {
    case iPhone = "120x120"
    case iPad = "152x152"
    case iPadPro = "167x167"
    case Mac = "1024x1024"
    
    var size: CGSize {
        let components = rawValue.split(separator: "x")
        guard components.count == 2,
              let width = Double(components[0]),
              let height = Double(components[1]) else {
            return CGSize(width: 100, height: 100) // Default size if parsing fails
        }
        return CGSize(width: width, height: height)
    }
}

/// App Store asset generation
struct AppStoreAssetGenerator {
    static func generateAppIcon() -> Image {
        Image(systemName: "smiley")
    }
    
    static func generateScreenshot(_ screenshot: Screenshot) -> Image {
        Image(systemName: "photo")
    }
}
