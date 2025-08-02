import SwiftUI
import Charts
import CoreData

/// Analytics view for mood tracking
struct AnalyticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedRange: DateRange = .week
    @State private var selectedDate = Date()
    
    enum DateRange: String, CaseIterable {
        case day = "Day"
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Date range selector
                Picker("Time Range", selection: $selectedRange) {
                    ForEach(DateRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Daily average
                VStack(alignment: .leading, spacing: 10) {
                    Text("Daily Average")
                        .font(.headline)
                    Text("\(dailyAverage, specifier: "%.1f")/10")
                        .font(.system(size: 40))
                        .foregroundColor(dailyAverage > 7 ? .green : dailyAverage < 4 ? .red : .blue)
                }
                .padding(.horizontal)
                
                // Mood trend chart
                Chart {
                    ForEach(moodTrendData) { data in
                        LineMark(
                            x: .value("Date", data.date),
                            y: .value("Mood", data.moodValue)
                        )
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .foregroundStyle(Color.purple)
                        
                        PointMark(
                            x: .value("Date", data.date),
                            y: .value("Mood", data.moodValue)
                        )
                        .foregroundStyle(Color.purple)
                    }
                }
                .chartXAxis {
                    AxisMarks()
                }
                .chartYAxis {
                    AxisMarks()
                }
                .padding(.horizontal)
                
                // Mood heatmap
                Text("Mood Heatmap")
                    .font(.headline)
                    .padding(.horizontal)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                    ForEach(heatmapData) { item in
                        HeatmapCell(
                            date: item.date,
                            moodValue: item.moodValue
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Analytics")
    }
    
    // MARK: - Data Processing
    
    private var dailyAverage: Double {
        let entries = fetchEntries(for: selectedRange)
        guard !entries.isEmpty else { return 0 }
        let total = entries.reduce(0) { $0 + Double($1.moodValue) }
        return total / Double(entries.count)
    }
    
    private var moodTrendData: [(date: Date, moodValue: Double)] {
        let entries = fetchEntries(for: selectedRange)
        return entries.map { ($0.dateTime, Double($0.moodValue)) }
    }
    
    private var heatmapData: [(date: Date, moodValue: Int16)] {
        let entries = fetchEntries(for: .month)
        return entries.map { ($0.dateTime, $0.moodValue) }
    }
    
    private func fetchEntries(for range: DateRange) -> [NSManagedObject] {
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "MoodEntry")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateTime", ascending: true)]
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        switch range {
        case .day:
            fetchRequest.predicate = NSPredicate(format: "dateTime >= %@ AND dateTime <= %@",
                                                calendar.startOfDay(for: selectedDate) as NSDate,
                                                calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: selectedDate))! as NSDate)
        case .week:
            let weekStart = calendar.date(byAdding: .day, value: -6, to: selectedDate)!
            fetchRequest.predicate = NSPredicate(format: "dateTime >= %@ AND dateTime <= %@",
                                                calendar.startOfDay(for: weekStart) as NSDate,
                                                calendar.startOfDay(for: selectedDate) as NSDate)
        case .month:
            let monthStart = calendar.date(byAdding: .month, value: -1, to: selectedDate)!
            fetchRequest.predicate = NSPredicate(format: "dateTime >= %@ AND dateTime <= %@",
                                                calendar.startOfDay(for: monthStart) as NSDate,
                                                calendar.startOfDay(for: selectedDate) as NSDate)
        case .year:
            let yearStart = calendar.date(byAdding: .year, value: -1, to: selectedDate)!
            fetchRequest.predicate = NSPredicate(format: "dateTime >= %@ AND dateTime <= %@",
                                                calendar.startOfDay(for: yearStart) as NSDate,
                                                calendar.startOfDay(for: selectedDate) as NSDate)
        }
        
        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching entries: \(error)")
            return []
        }
    }
}

/// Heatmap cell view
struct HeatmapCell: View {
    let date: Date
    let moodValue: Int16
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(colorForMood(moodValue))
            Text(date.formatted(date: .weekday, time: .omitted))
                .font(.caption)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func colorForMood(_ value: Int16) -> Color {
        switch value {
        case 1...2: return .red
        case 3...4: return .orange
        case 5: return .yellow
        case 6...7: return .green
        case 8...10: return .green.opacity(0.8)
        default: return .gray
        }
    }
}

struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
