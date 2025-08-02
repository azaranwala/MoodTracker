import SwiftUI
import UserNotifications

/// Settings view for app preferences
struct SettingsView: View {
    @AppStorage("theme") private var themeRawValue: String = "System"
    @AppStorage("reminderEnabled") private var reminderEnabled = false
    @AppStorage("reminderTime") private var reminderTimeRawValue: String = ""
    @AppStorage("reminderFrequency") private var reminderFrequencyRawValue: String = "Daily"
    @State private var showingExport = false
    @State private var showingPrivacy = false
    
    private var selectedTheme: Binding<Theme> {
        Binding(
            get: { Theme(rawValue: themeRawValue) ?? .system },
            set: { themeRawValue = $0.rawValue }
        )
    }
    
    private var selectedFrequency: Binding<ReminderFrequency> {
        Binding(
            get: { ReminderFrequency(rawValue: reminderFrequencyRawValue) ?? .daily },
            set: { reminderFrequencyRawValue = $0.rawValue }
        )
    }
    
    private var reminderTime: Binding<Date> {
        Binding(
            get: {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm"
                return formatter.date(from: reminderTimeRawValue) ?? Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
            },
            set: {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm"
                reminderTimeRawValue = formatter.string(from: $0)
            }
        )
    }
    
    enum Theme: String, CaseIterable, Identifiable {
        case system = "System"
        case light = "Light"
        case dark = "Dark"
        
        var id: String { self.rawValue }
    }
    
    enum ReminderFrequency: String, CaseIterable, Identifiable {
        case daily = "Daily"
        case twiceDaily = "Twice Daily"
        case custom = "Custom"
        
        var id: String { self.rawValue }
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Theme section
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: selectedTheme) {
                        ForEach(Theme.allCases) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                }
                
                // Reminders section
                Section(header: Text("Reminders")) {
                    Toggle("Enable Mood Reminders", isOn: $reminderEnabled)
                        .onChange(of: reminderEnabled) { enabled in
                            if enabled {
                                requestNotificationPermission()
                            } else {
                                removeAllNotifications()
                            }
                        }
                    
                    if reminderEnabled {
                        DatePicker("Reminder Time", selection: reminderTime, displayedComponents: .hourAndMinute)
                        
                        Picker("Frequency", selection: selectedFrequency) {
                            ForEach(ReminderFrequency.allCases) { freq in
                                Text(freq.rawValue).tag(freq)
                            }
                        }
                    }
                }
                
                // Export section
                Section(header: Text("Data Export")) {
                    Button(action: { showingExport = true }) {
                        HStack {
                            Text("Export Data")
                            Spacer()
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                    .sheet(isPresented: $showingExport) {
                        NavigationView {
                            ExportView()
                        }
                    }
                }
                
                // Privacy section
                Section(header: Text("Privacy")) {
                    Button(action: { showingPrivacy = true }) {
                        HStack {
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "info.circle")
                        }
                    }
                    .sheet(isPresented: $showingPrivacy) {
                        NavigationView {
                            PrivacyView()
                                .toolbar {
                                    ToolbarItem(placement: .navigationBarTrailing) {
                                        Button("Done") {
                                            showingPrivacy = false
                                        }
                                    }
                                }
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    // MARK: - Notification Management
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                scheduleNotifications()
            }
        }
    }
    
    private func scheduleNotifications() {
        let content = UNMutableNotificationContent()
        content.title = "Check Your Mood"
        content.body = "How are you feeling today?"
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: reminderTime.wrappedValue)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                           content: content,
                                           trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

/// View for exporting data
struct ExportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var exportFormat: ExportFormat = .csv
    
    enum ExportFormat: String, CaseIterable {
        case csv = "CSV"
        case json = "JSON"
    }
    
    var body: some View {
        Form {
            Section {
                Picker("Export Format", selection: $exportFormat) {
                    ForEach(ExportFormat.allCases, id: \.self) { format in
                        Text(format.rawValue).tag(format)
                    }
                }
            }
            
            Section {
                Button(action: exportData) {
                    Text("Export Data")
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationTitle("Export Data")
        .navigationBarItems(trailing: Button("Done") { dismiss() })
    }
    
    private func exportData() {
        // TODO: Implement data export functionality
    }
}

/// View for privacy policy
struct PrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Policy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Data Collection")
                    .font(.headline)
                Text("We collect only the mood data you enter into the app. No other personal data is collected.")
                
                Text("Data Storage")
                    .font(.headline)
                Text("Your mood data is stored locally on your device. We do not collect or store any data on our servers.")
                
                Text("Export")
                    .font(.headline)
                Text("You can export your mood data at any time through the Settings menu.")
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
