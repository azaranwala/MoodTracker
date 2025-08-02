import SwiftUI
import CoreData

/// History view for viewing all mood entries
struct HistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var searchText = ""
    @State private var selectedFilter: MoodFilter = .all
    @State private var showFilters = false
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    // Fetch request with sorting by date
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MoodEntry.dateTime, ascending: false)],
        animation: .default
    ) private var entries: FetchedResults<MoodEntry>
    
    // Filtered entries based on search and filter
    private var filteredEntries: [MoodEntry] {
        var predicates: [NSPredicate] = []
        
        // Add search text filter
        if !searchText.isEmpty {
            predicates.append(NSPredicate(format: "note CONTAINS[cd] %@", searchText))
        }
        
        // Add mood value filter
        switch selectedFilter {
        case .bad:
            predicates.append(NSPredicate(format: "moodValue < 4"))
        case .neutral:
            predicates.append(NSPredicate(format: "moodValue >= 4 AND moodValue <= 7"))
        case .good:
            predicates.append(NSPredicate(format: "moodValue > 7"))
        case .all:
            break
        }
        
        // If no predicates, return all entries
        if predicates.isEmpty {
            return Array(entries)
        }
        
        // Combine all predicates with AND
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        return entries.filter { compoundPredicate.evaluate(with: $0) }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Main content
                VStack {
                    // Search bar
                    SearchBar(text: $searchText, placeholder: "Search notes...")
                        .padding(.horizontal)
                    
                    // Filter pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(MoodFilter.allCases, id: \.self) { filter in
                                FilterPill(
                                    title: filter.rawValue,
                                    isSelected: selectedFilter == filter,
                                    action: { selectedFilter = filter }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                    
                    // Entries list
                    if isLoading {
                        ProgressView("Loading entries...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if filteredEntries.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "tray")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            Text("No entries found")
                                .font(.title3)
                                .foregroundColor(.secondary)
                            if !searchText.isEmpty || selectedFilter != .all {
                                Button("Clear filters") {
                                    searchText = ""
                                    selectedFilter = .all
                                }
                                .foregroundColor(.purple)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(filteredEntries, id: \.id) { entry in
                                NavigationLink(destination: MoodDetailEntryView(entry: entry)) {
                                    HistoryEntryRow(entry: entry)
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        deleteEntry(entry)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                    }
                }
                
                // Error message overlay
                if let errorMessage = errorMessage {
                    VStack {
                        Text(errorMessage)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(8)
                            .padding(.top)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                self.errorMessage = nil
                            }
                        }
                    }
                }
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showFilters.toggle() }) {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showFilters) {
                FilterView(selectedFilter: $selectedFilter)
            }
            .onAppear {
                loadEntries()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadEntries() {
        isLoading = true
        errorMessage = nil
        
        do {
            // Create a new fetch request
            let fetchRequest: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \MoodEntry.dateTime, ascending: false)]
            
            // Execute the fetch request
            let fetchedEntries = try viewContext.fetch(fetchRequest)
            print("✅ Loaded \(fetchedEntries.count) entries")
            
            // Force refresh the fetch request results
            try viewContext.save()
            
        } catch {
            print("❌ Failed to fetch entries: \(error)")
            errorMessage = "Failed to load entries. Please try again."
            
            // If there's an error, try to fetch without saving
            do {
                try viewContext.fetch(MoodEntry.fetchRequest())
            } catch {
                print("❌ Secondary fetch also failed: \(error)")
            }
        }
        
        isLoading = false
    }
    
    private func deleteEntry(_ entry: MoodEntry) {
        withAnimation {
            viewContext.delete(entry)
            
            do {
                try viewContext.save()
                print("✅ Deleted entry: \(entry.id?.uuidString ?? "unknown")")
            } catch {
                print("❌ Failed to delete entry: \(error)")
                errorMessage = "Failed to delete entry. Please try again."
                
                // Attempt to undo the deletion
                viewContext.rollback()
            }
        }
    }
}

// MARK: - Supporting Views

private struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

private struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.purple : Color(.systemGray5))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Supporting Types

enum MoodFilter: String, CaseIterable {
    case all = "All"
    case bad = "Bad"
    case neutral = "Neutral"
    case good = "Good"
}

struct HistoryEntryRow: View {
    let entry: MoodEntry
    
    var body: some View {
        HStack {
            // Get emoji for current mood value
            let emojis = ["😢", "😞", "😐", "🙂", "😊", "😄", "🤩"]
            let index = min(max(0, Int(entry.moodValue) / 2), emojis.count - 1)
            Text(emojis[index])
                .font(.title2)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Color.purple.opacity(0.1)))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(entry.moodValue)/10")
                    .font(.headline)
                
                if let note = entry.note, !note.isEmpty {
                    Text(note)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                if let date = entry.dateTime {
                    Text(date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct MoodDetailEntryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var entry: MoodEntry
    @State private var note: String
    @State private var showingDeleteAlert = false
    @State private var errorMessage: String? = nil
    
    // Emoji array for mood display
    private let emojis = ["😢", "😞", "😐", "🙂", "😊", "😄", "🤩"]
    
    init(entry: MoodEntry) {
        self.entry = entry
        self._note = State(initialValue: entry.note ?? "")
    }
    
    private var moodEmoji: String {
        let index = min(max(0, Int(entry.moodValue) / 2), emojis.count - 1)
        return emojis[index]
    }
    
    private var moodDescription: String {
        let moodValue = Int(entry.moodValue)
        switch moodValue {
        case 1...2: return "Very Bad"
        case 3...4: return "Bad"
        case 5...6: return "Neutral"
        case 7...8: return "Good"
        case 9...10: return "Great"
        default: return "Unknown"
        }
    }
    
    private func saveChanges() {
        do {
            entry.note = note.isEmpty ? nil : note
            try viewContext.save()
            dismiss()
        } catch {
            errorMessage = "Failed to save changes: \(error.localizedDescription)"
        }
    }
    
    private func deleteEntry() {
        viewContext.delete(entry)
        do {
            try viewContext.save()
            dismiss()
        } catch {
            errorMessage = "Failed to delete entry: \(error.localizedDescription)"
        }
    }
    
    @State private var showingErrorAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                moodSection
                noteSection
                dateSection
                actionButtons
            }
            .navigationTitle("Mood Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                }
            }
            .alert("Delete Entry", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive, action: deleteEntry)
            } message: {
                Text("Are you sure you want to delete this entry? This action cannot be undone.")
            }
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }
    
    private var moodSection: some View {
        Section(header: Text("Mood")) {
            HStack {
                Text(moodEmoji)
                    .font(.largeTitle)
                    .frame(width: 60, height: 60)
                    .background(Circle().fill(Color.purple.opacity(0.1)))
                
                VStack(alignment: .leading) {
                    Text("\(entry.moodValue)/10")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    // Display mood description
                    Text(moodDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.leading, 8)
            }
            .padding(.vertical, 8)
        }
    }
    
    private var noteSection: some View {
        Section(header: Text("Note")) {
            TextEditor(text: $note)
                .frame(minHeight: 100)
        }
    }
    
    @ViewBuilder
    private var dateSection: some View {
        if let date = entry.dateTime {
            Section(header: Text("Date")) {
                Text(date.formatted(date: .long, time: .shortened))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var actionButtons: some View {
        Section {
            Button(action: saveChanges) {
                HStack {
                    Spacer()
                    Text("Save Changes")
                        .fontWeight(.semibold)
                    Spacer()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                HStack {
                    Spacer()
                    Text("Delete Entry")
                        .foregroundColor(.red)
                    Spacer()
                }
            }
            .buttonStyle(.bordered)
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
        .padding(.top, 8)
    }
}

struct FilterView: View {
    @Binding var selectedFilter: MoodFilter
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(MoodFilter.allCases, id: \.self) { filter in
                Button(action: {
                    selectedFilter = filter
                    dismiss()
                }) {
                    HStack {
                        Text(filter.rawValue)
                        Spacer()
                        if selectedFilter == filter {
                            Image(systemName: "checkmark")
                                .foregroundColor(.purple)
                        }
                    }
                }
                .foregroundColor(.primary)
            }
            .navigationTitle("Filter by Mood")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        return HistoryView()
            .environment(\.managedObjectContext, context)
    }
}
