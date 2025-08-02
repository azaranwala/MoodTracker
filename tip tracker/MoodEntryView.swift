import SwiftUI
import CoreData

/// Home tab view for mood entry
struct MoodEntryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedDate = Date()
    @State private var moodValue = 5
    @State private var note = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header with date
                HStack {
                    Text(selectedDate.formatted(date: .complete, time: .omitted))
                        .font(.title)
                    Spacer()
                    Button(action: { selectedDate = Date() }) {
                        Text("Today")
                            .foregroundColor(.purple)
                    }
                }
                .padding(.horizontal)
                
                // Calendar
                DatePicker("Select Date", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding(.horizontal)
                
                // Mood slider section
                VStack(spacing: 10) {
                    Text("How are you feeling?")
                        .font(.headline)
                    
                    // Mood slider
                    Slider(value: $moodValue, in: 1...10, step: 1) {
                        Text("Mood")
                    } minimumValueLabel: {
                        Text("1")
                    } maximumValueLabel: {
                        Text("10")
                    }
                    .padding(.horizontal)
                    
                    // Mood display
                    HStack {
                        Text(MoodEntry.emoji(for: Int(moodValue)))
                            .font(.system(size: 40))
                        Spacer()
                        Text(MoodEntry.description(forMoodValue: Int(moodValue)))
                            .font(.title3)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                
                // Note input
                TextField("Add a note...", text: $note)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                // Save button
                Button(action: saveMoodEntry) {
                    Text("Save Mood Entry")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Recent entries
                Text("Recent Entries")
                    .font(.headline)
                    .padding(.horizontal)
                
                List(fetchRecentEntries()) { entry in
                    MoodEntryRow(entry: entry)
                }
                .listStyle(.plain)
            }
            .padding(.top)
        }
        .navigationTitle("Mood Tracker")
    }
    
    // MARK: - Core Data Operations
    
    private func saveMoodEntry() {
        let newEntry = MoodEntry(moodValue: Int(moodValue), note: note.isEmpty ? nil : note)
        
        // Save to Core Data
        let context = viewContext
        let entity = NSEntityDescription.entity(forEntityName: "MoodEntry", in: context)!
        let entry = NSManagedObject(entity: entity, insertInto: context)
        
        entry.id = newEntry.id
        entry.dateTime = newEntry.dateTime
        entry.moodValue = Int16(newEntry.moodValue)
        entry.emoji = newEntry.emoji
        entry.note = newEntry.note
        
        do {
            try context.save()
            note = "" // Clear note field after saving
        } catch {
            print("Error saving mood entry: \(error)")
        }
    }
    
    private func fetchRecentEntries() -> [NSManagedObject] {
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "MoodEntry")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateTime", ascending: false)]
        fetchRequest.fetchLimit = 5
        
        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching recent entries: \(error)")
            return []
        }
    }
}

/// View for displaying a single mood entry in the list
struct MoodEntryRow: View {
    let entry: NSManagedObject
    
    var body: some View {
        HStack(spacing: 16) {
            Text(entry.dateTime.formatted(date: .abbreviated, time: .shortened))
            Text(entry.emoji)
                .font(.system(size: 24))
            Text("\(entry.moodValue)/10")
            Spacer()
            if let note = entry.note {
                Text(note)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
}

struct MoodEntryView_Previews: PreviewProvider {
    static var previews: some View {
        MoodEntryView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
