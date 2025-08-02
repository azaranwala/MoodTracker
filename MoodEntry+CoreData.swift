import Foundation
import CoreData

@objc(MoodEntry)
public class MoodEntry: NSManagedObject, Identifiable {
    
    // MARK: - Core Data Properties
    @NSManaged public var id: UUID?
    @NSManaged public var dateTime: Date?
    @NSManaged public var moodValue: Int16
    @NSManaged public var emojiString: String?
    @NSManaged public var note: String?
    
    // MARK: - Public Properties
    
    /// Returns the emoji representation of the mood
    /// - Note: If emojiString is nil, it falls back to the default emoji for the mood value
    public var emoji: String {
        get {
            let emoji = emojiString ?? MoodEntry.emoji(for: Int(moodValue))
            #if DEBUG
            print("[MoodEntry] Getting emoji for mood \(moodValue): \(emoji)")
            #endif
            return emoji
        }
        set {
            #if DEBUG
            print("[MoodEntry] Setting emoji to: \(newValue) for mood: \(moodValue)")
            #endif
            emojiString = newValue
        }
    }
    
    /// Returns a human-readable description of the mood value
    @objc public dynamic var moodDescription: String {
        return MoodEntry.description(forMoodValue: Int(moodValue))
    }
    
    // MARK: - Convenience Initializer
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MoodEntry> {
        return NSFetchRequest<MoodEntry>(entityName: "MoodEntry")
    }
    
    // MARK: - Helpers
    
    /// Returns an emoji based on the mood value (1-10)
    /// - Parameter moodValue: The mood value from 1 to 10
    /// - Returns: An emoji string representing the mood
    public static func emoji(for moodValue: Int) -> String {
        let emojis = ["😢", "😞", "😐", "🙂", "😊", "😄", "🤩"]
        let index = min(max(0, moodValue / 2), emojis.count - 1)
        let emoji = emojis[index]
        
        #if DEBUG
        print("[MoodEntry] Generated emoji for mood \(moodValue): \(emoji)")
        #endif
        
        return emoji
    }
    
    public static func description(forMoodValue moodValue: Int) -> String {
        switch moodValue {
        case 1...2: return "Very Bad"
        case 3...4: return "Bad"
        case 5...6: return "Neutral"
        case 7...8: return "Good"
        case 9...10: return "Great"
        default: return "Unknown"
        }
    }
    
    // iOS 16+ compatibility for date formatting
    @available(iOS 15.0, *)
    public func formattedDateTime() -> String {
        guard let date = dateTime else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Preview Support
#if DEBUG
public extension MoodEntry {
    static func createPreviewEntry(in context: NSManagedObjectContext, moodValue: Int16 = 7, date: Date = Date(), note: String? = nil) -> MoodEntry {
        let entry = MoodEntry(context: context)
        entry.id = UUID()
        entry.dateTime = date
        entry.moodValue = moodValue
        entry.emoji = MoodEntry.emoji(for: Int(moodValue))
        entry.note = note
        return entry
    }
}
#endif
