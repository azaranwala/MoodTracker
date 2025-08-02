import Foundation

/// Data model representing a single mood entry
struct MoodEntry: Identifiable, Codable {
    let id: UUID
    let dateTime: Date
    let moodValue: Int
    var emoji: String
    var note: String?
    
    /// Initialize with mood value and optional note
    init(moodValue: Int, note: String? = nil) {
        self.id = UUID()
        self.dateTime = Date()
        self.moodValue = moodValue
        self.emoji = MoodEntry.emoji(for: moodValue)
        self.note = note
    }
    
    /// Get emoji for mood value
    static func emoji(for value: Int) -> String {
        switch value {
        case 1...2: return "😞"
        case 3...4: return "😕"
        case 5: return "😐"
        case 6...7: return "🙂"
        case 8...9: return "😃"
        case 10: return "😄"
        default: return "😐"
        }
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
}
