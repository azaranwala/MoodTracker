import SwiftUI
import CoreData

/// History view for viewing all mood entries
struct HistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedFilter: MoodFilter = .all
    @State private var searchText = ""
    @State private var selectedDateRange: DateRange = .all
    
    enum MoodFilter: String, CaseIterable {
        case all = "All"
        case bad = "Bad (1-4)"
        case neutral = "Neutral (5)"
        case good = "Good (6-10)"
    }
    
    enum DateRange: String, CaseIterable {
        case all = "All Time"
        case month = "Last Month"
        case year = "Last Year"
    }
    
    var body: some View {
        NavigationView {
            List {
                // Filter section
                Section {
                    Picker("Mood Filter", selection: $selectedFilter) {
                        ForEach(MoodFilter.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    
                    Picker("Date Range", selection: $selectedDateRange) {
                        ForEach(DateRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                } header: {
                    Text("Filters")
                }
                
                // Mood entries
                ForEach(filteredEntries) { entry in
                    NavigationLink {
                        MoodDetailEntryView(entry: entry)
                    } label: {
                        MoodEntryRow(entry: entry)
                    }
                }
            }
            .navigationTitle("History")
            .searchable(text: $searchText, prompt: "Search notes...")
            .toolbar {
                EditButton()
            }
        }
    }
    
    // MARK: - Data Processing
    
    private var filteredEntries: [NSManagedObject] {
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "MoodEntry")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateTime", ascending: false)]
        
        var predicates: [NSPredicate] = []
        
        // Add mood filter predicate
        if selectedFilter != .all {
            let valueRange: ClosedRange<Int16>
            switch selectedFilter {
            case .bad: valueRange = 1...4
            case .neutral: valueRange = 5...5
            case .good: valueRange = 6...10
            default: valueRange = 1...10
            }
            predicates.append(NSPredicate(format: "moodValue >= %d AND moodValue <= %d",
                                        valueRange.lowerBound, valueRange.upperBound))
        }
        
        // Add date range predicate
        if selectedDateRange != .all {
            var calendar = Calendar.current
            calendar.timeZone = TimeZone.current
            
            let startDate: Date
            switch selectedDateRange {
            case .month:
                startDate = calendar.date(byAdding: .month, value: -1, to: Date())!
            case .year:
                startDate = calendar.date(byAdding: .year, value: -1, to: Date())!
            default:
                startDate = Date.distantPast
            }
            predicates.append(NSPredicate(format: "dateTime >= %@", startDate as NSDate))
        }
        
        // Add search predicate
        if !searchText.isEmpty {
            predicates.append(NSPredicate(format: "note CONTAINS[cd] %@", searchText))
        }
        
        if !predicates.isEmpty {
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching entries: \(error)")
            return []
        }
    }
}

/// View for displaying a single mood entry in detail
struct MoodDetailEntryView: View {
    let entry: NSManagedObject
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Date and time
                Text(entry.dateTime.formatted(date: .complete, time: .shortened))
                    .font(.headline)
                
                // Mood display
                HStack {
                    Text(entry.emoji)
                        .font(.system(size: 40))
                    Spacer()
                    Text("\(entry.moodValue)/10")
                        .font(.title2)
                }
                
                // Note
                if let note = entry.note {
                    Text("Note")
                        .font(.headline)
                    Text(note)
                        .font(.body)
                        .foregroundColor(.gray)
                }
            }
            .padding()
        }
        .navigationTitle("Mood Entry")
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
