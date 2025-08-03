import SwiftUI
import CoreData
import UIKit

// MARK: - Screen Size Detection
enum ScreenSize {
    static var width: CGFloat { UIScreen.main.bounds.width }
    static var height: CGFloat { UIScreen.main.bounds.height }
    
    // Base dimensions for reference (iPhone 12 Pro - 6.1")
    private static let baseWidth: CGFloat = 390
    private static let baseHeight: CGFloat = 844
    
    // Scale factor based on screen width
    static var scaleFactor: CGFloat {
        min(width / baseWidth, height / baseHeight)
    }
    
    // Dynamic font size calculator
    static func dynamicFontSize(_ size: CGFloat) -> CGFloat {
        return size * scaleFactor
    }
    
    // Dynamic padding calculator
    static func dynamicPadding(_ size: CGFloat) -> CGFloat {
        return size * scaleFactor
    }
}

// MARK: - Mood Description Helper
private func moodDescription(for value: Int) -> String {
    switch value {
    case 1...2: return "Very Bad"
    case 3...4: return "Bad"
    case 5...6: return "Neutral"
    case 7...8: return "Good"
    case 9...10: return "Great"
    default: return ""
    }
}
//Create a MoodEntryView struct
struct MoodEntryView: View {
    @Environment(\.managedObjectContext) var viewContext
    @State private var selectedDate = Date()
    @State private var moodValue = 5
    @State private var note = ""
    
    // Dynamic sizing properties
    private var isSmallScreen: Bool {
        ScreenSize.width < 375 // iPhone SE, 5s, etc.
    }
    
    private var isLargeScreen: Bool {
        ScreenSize.width >= 428 // iPhone 14 Pro Max, 13 Pro Max, etc.
    }
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MoodEntry.dateTime, ascending: false)],
        animation: .default
    ) var recentEntries: FetchedResults<MoodEntry>
    
    // Date formatter for iOS 16+ compatibility
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }
    
    // Helper function to get emoji for mood value
    private func emojiForMood(_ value: Int) -> String {
        let emojis = ["😢", "😞", "😐", "🙂", "😊", "😄", "🤩"]
        let index = min(max(0, value / 2), emojis.count - 1)
        return emojis[index]
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Main content in a scroll view
                ScrollView {
                    VStack(spacing: 20) {
                    // Header with date
                    HStack {
                        Text(selectedDate, formatter: dateFormatter)
                            .font(.system(size: ScreenSize.dynamicFontSize(16)))
                        
                        Spacer()
                        
                        Button(action: { selectedDate = Date() }) {
                            Text("Today")
                                .font(.system(size: ScreenSize.dynamicFontSize(16)))
                                .foregroundColor(.purple)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Calendar - Responsive DatePicker
                    DatePicker("Select Date", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .scaleEffect(isSmallScreen ? 0.9 : 1.0) // Scale down for smaller screens
                        .padding(.vertical, isSmallScreen ? 5 : 10)
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal, ScreenSize.dynamicPadding(16))
                    
                    // Mood slider section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("How are you feeling?")
                            .font(.system(size: ScreenSize.dynamicFontSize(18), weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, ScreenSize.dynamicPadding(16))
                            .padding(.top, isSmallScreen ? 5 : 10)
                        
                        // Mood scale container
                        VStack(spacing: 10) {
                            // Current mood display
                            HStack {
                                // Display mood emoji
                                Text(emojiForMood(moodValue))
                                    .font(.system(size: isSmallScreen ? 32 : 40))
                                    .frame(width: isSmallScreen ? 40 : 50, alignment: .center)
                                
                                // Display mood value
                                Text("\(moodValue)/10")
                                    .font(.system(size: ScreenSize.dynamicFontSize(24), weight: .bold))
                                    .foregroundColor(.purple)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal)
                            
                            // Mood slider container with fixed height
                            VStack(spacing: 20) {
                                // Large emoji display
                                Text(emojiForMood(moodValue))
                                    .font(.system(size: isSmallScreen ? 50 : 60))
                                    .padding(.bottom, isSmallScreen ? 2 : 5)
                                
                                // Debug info - Hidden in production
                                Text("Mood: \(moodValue)/10")
                                    .font(.system(size: ScreenSize.dynamicFontSize(14)))
                                    .foregroundColor(.purple)
                                    .opacity(0.7) // Make it more subtle
                                
                                // Simple slider implementation
                                VStack {
                                    // Slider with explicit frame
                                    Slider(
                                        value: Binding(
                                            get: { Double(moodValue) },
                                            set: { moodValue = Int($0.rounded()) }
                                        ),
                                        in: 1...10,
                                        step: 1,
                                        minimumValueLabel: Text("1").foregroundColor(.secondary),
                                        maximumValueLabel: Text("10").foregroundColor(.secondary)
                                    ) {
                                        Text("Mood")
                                    }
                                    .labelsHidden()
                                    .tint(.purple)
                                    .padding(.horizontal, ScreenSize.dynamicPadding(12))
                                    .padding(.vertical, ScreenSize.dynamicPadding(8))
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.gray.opacity(0.1))
                                    )
                                    .frame(height: isSmallScreen ? 50 : 60) // Adjust height based on screen size
                                    
                                    // Visual indicator of mood level
                                    HStack {
                                        ForEach(1...10, id: \.self) { index in
                                            Rectangle()
                                                .fill(index <= moodValue ? Color.purple : Color.gray.opacity(0.3))
                                                .frame(height: 6)
                                                .cornerRadius(3)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                                
                                // Mood description
                                Text(moodDescription(for: moodValue))
                                    .font(.system(size: ScreenSize.dynamicFontSize(16), weight: .semibold))
                                    .foregroundColor(.purple)
                                    .padding(.top, isSmallScreen ? 2 : 5)
                            }
                            .padding(ScreenSize.dynamicPadding(12))
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(.secondarySystemBackground))
                            )
                            .padding(.horizontal, ScreenSize.dynamicPadding(10))
                            .padding(.vertical, isSmallScreen ? 5 : 10)
                        }
                    }
                    .padding(.vertical, 10)
                    
                    // Note input
                    TextField("Add a note...", text: $note)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.system(size: ScreenSize.dynamicFontSize(16)))
                        .padding(.horizontal, ScreenSize.dynamicPadding(16))
                        .padding(.vertical, isSmallScreen ? 5 : 10)
                    
                    // Recent entries header
                    if !recentEntries.isEmpty {
                        Text("Recent Entries")
                            .font(.system(size: ScreenSize.dynamicFontSize(18), weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, ScreenSize.dynamicPadding(16))
                            .padding(.top, isSmallScreen ? 10 : 15)
                        
                        ForEach(Array(recentEntries.prefix(3)), id: \.self) { entry in
                            MoodEntryRow(entry: entry)
                                .padding(.horizontal)
                        }
                    }
                    
                    }
                    .padding(.top)
                    .padding(.bottom, 80) // Add bottom padding to prevent content from being hidden behind the button
                }
                
                // Fixed Save Button at bottom - outside of ScrollView
                VStack {
                    Spacer()
                    Button(action: saveMoodEntry) {
                        HStack {
                            Spacer()
                            Text("💾 SAVE MOOD ENTRY")
                                .font(.system(size: ScreenSize.dynamicFontSize(16), weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.vertical, isSmallScreen ? 12 : 16)
                            Spacer()
                        }
                        .background(Color.purple)
                        .cornerRadius(10)
                        .padding(.horizontal, ScreenSize.dynamicPadding(16))
                        .padding(.bottom, isSmallScreen ? 16 : 24)
                    }
                    .background(Color(.systemBackground).shadow(radius: 0.5))
                    .frame(maxWidth: .infinity)
                }
                .frame(height: 80) // Fixed height for the button container
            }
        }
        .navigationTitle("Mood Tracker")
    }

    func saveMoodEntry() {
        print("💾 Attempting to save mood entry...")
        
        // Create a new managed object context for this operation
        let context = PersistenceController.shared.container.viewContext
        
        // Create a new MoodEntry
        let newEntry = MoodEntry(context: viewContext)
        newEntry.id = UUID()
        newEntry.dateTime = selectedDate
        newEntry.moodValue = Int16(moodValue)
        // Set the mood value and emoji
        newEntry.moodValue = Int16(moodValue)
        let emojis = ["😢", "😞", "😐", "🙂", "😊", "😄", "🤩"]
        let index = min(max(0, moodValue / 2), emojis.count - 1)
        newEntry.emoji = emojis[index]
        print("🔵 Setting emoji for mood value \(moodValue): \(emojis[index])")
        newEntry.note = note.isEmpty ? nil : note
        
        // Debug print the entry being saved
        print("📝 New Entry Details:")
        print("  - ID: \(newEntry.id?.uuidString ?? "nil")")
        print("  - Date: \(newEntry.dateTime?.description ?? "nil")")
        print("  - Mood Value: \(newEntry.moodValue)")
        print("  - Emoji: \(newEntry.emoji ?? "nil")")
        print("  - Note: \(newEntry.note ?? "nil")")
        
        do {
            // Save the context
            try context.save()
            print("✅ Successfully saved mood entry")
            
            // Reset the form
            note = ""
            moodValue = 5 // Reset to neutral
            
            // Trigger haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Dismiss keyboard if it's showing
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            
            // Force refresh the view
            NotificationCenter.default.post(name: NSManagedObjectContext.didSaveObjectsNotification, object: context)
            
        } catch {
            // Handle the error
            let nsError = error as NSError
            print("❌ Unresolved error saving mood entry: \(nsError), \(nsError.userInfo)")
            
            // Show error feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
        
        // Force fetch the latest entries
        fetchRecentEntries()
    }
    
    func fetchRecentEntries() {
        // The @FetchRequest will automatically update the view
        // when the data changes, so we don't need to do anything here
        // Just log the current count for debugging
        print("🔍 Fetched \(recentEntries.count) entries")
    }
}

/// View for displaying a single mood entry in the list
struct MoodEntryRow: View {
    @ObservedObject var entry: MoodEntry
    
    var body: some View {
        HStack {
            // Display the emoji with a default value if nil
            let emojiToShow = entry.emoji ?? "😐" // Default to neutral emoji if nil
            Text(emojiToShow)
                .font(.title2)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Color.purple.opacity(0.1)))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(entry.moodValue)/10")
                    .font(.headline)
                
                if let date = entry.dateTime {
                    Text(date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let note = entry.note, !note.isEmpty {
                    Text(note)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            if let date = entry.dateTime {
                Text(date, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview Provider

struct MoodEntryView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        // Create a sample entry for preview
        let sampleEntry = MoodEntry(context: context)
        sampleEntry.id = UUID()
        sampleEntry.dateTime = Date()
        sampleEntry.moodValue = 7
        // Set sample mood value and emoji
        sampleEntry.moodValue = 7
        let emojis = ["😢", "😞", "😐", "🙂", "😊", "😄", "🤩"]
        let previewEmoji = emojis[3] // 😊 for mood value 7
        sampleEntry.emoji = previewEmoji
        print("🔵 Preview emoji set to: \(previewEmoji)")
        sampleEntry.note = "Feeling good today!"
        
        return NavigationView {
            MoodEntryView()
                .environment(\.managedObjectContext, context)
        }
    }
}
