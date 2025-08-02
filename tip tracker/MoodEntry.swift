import Foundation

/// Data model representing a single mood entry
struct MoodEntry: Identifiable, Codable {
    let id: UUID
    let dateTime: Date
    let moodValue: Int
    var emoji: String
    var note: String?
    
    /// Initialize with mood value and optional note
    /// - Parameters:
    ///   - moodValue: The mood value from 1 to 10
    ///   - note: Optional note about the mood
    init(moodValue: Int, note: String? = nil) {
        self.id = UUID()
        self.dateTime = Date()
        self.moodValue = moodValue
        self.emoji = MoodEntry.emoji(for: moodValue)
        self.note = note
        
        #if DEBUG
        print("[MoodEntry] Created new entry with mood: \(moodValue), emoji: \(self.emoji)")
        #endif
    }
    
    /// Returns an emoji based on the mood value (1-10)
    /// - Parameter value: The mood value from 1 to 10
    /// - Returns: An emoji string representing the mood
    /// - Note: Uses a different set of emojis than the Core Data version for variety
    static func emoji(for value: Int) -> String {
        let emoji: String
        
        switch value {
        case 1...2: emoji = "😞"
        case 3...4: emoji = "😕"
        case 5: emoji = "😐"
        case 6...7: emoji = "🙂"
        case 8...9: emoji = "😃"
        case 10: emoji = "😄"
        default: emoji = "😐"
        }
        
        #if DEBUG
        print("[MoodEntry] Generated emoji for mood \(value): \(emoji)")
        #endif
        
        return emoji
    }
    
    /// Get mood description for value
    static func description(for value: Int) -> String {
        switch value {
        case 1...2: return "Very Bad"
        case 3...4: return "Bad"
        case 5: return "Neutral"
        case 6...7: return "Okay"
        case 8...9: return "Good"
        case 10: return "Great"
        default: return "Neutral"
        }
    }
    
    /// Returns a human-readable description of the mood value
    var moodDescription: String {
        return MoodEntry.description(for: moodValue)
    }
}
