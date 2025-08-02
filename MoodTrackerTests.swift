import XCTest
@testable import MoodTracker

/// Tests for MoodTracker app
final class MoodTrackerTests: XCTestCase {
    // MARK: - MoodEntry Tests
    func testMoodEntryCreation() {
        let entry = MoodEntry(moodValue: 8)
        XCTAssertTrue(entry.id != UUID())
        XCTAssertEqual(entry.moodValue, 8)
        XCTAssertEqual(entry.emoji, "😃")
        XCTAssertEqual(entry.note, nil)
    }
    
    func testMoodEmojiMapping() {
        XCTAssertEqual(MoodEntry.emoji(for: 1), "😞")
        XCTAssertEqual(MoodEntry.emoji(for: 3), "😕")
        XCTAssertEqual(MoodEntry.emoji(for: 5), "😐")
        XCTAssertEqual(MoodEntry.emoji(for: 7), "🙂")
        XCTAssertEqual(MoodEntry.emoji(for: 10), "😄")
    }
    
    func testMoodDescriptionMapping() {
        XCTAssertEqual(MoodEntry.description(forMoodValue: 2), "Very Bad")
        XCTAssertEqual(MoodEntry.description(forMoodValue: 4), "Bad")
        XCTAssertEqual(MoodEntry.description(forMoodValue: 5), "Neutral")
        XCTAssertEqual(MoodEntry.description(forMoodValue: 7), "Okay")
        XCTAssertEqual(MoodEntry.description(forMoodValue: 9), "Good")
        XCTAssertEqual(MoodEntry.description(forMoodValue: 10), "Great")
    }
    
    // MARK: - NotificationManager Tests
    func testNotificationAuthorization() async {
        let manager = NotificationManager.shared
        let status = await manager.requestAuthorization()
        XCTAssertTrue(status)
    }
    
    func testNotificationScheduling() {
        let manager = NotificationManager.shared
        let date = Date()
        manager.scheduleReminders(time: date, frequency: .daily)
        
        let center = UNUserNotificationCenter.current()
        let requests = center.pendingNotificationRequests()
        XCTAssertTrue(!requests.isEmpty)
    }
    
    // MARK: - UI Tests
    func testHomeTabLayout() {
        let app = XCUIApplication()
        app.launch()
        
        // Verify tab bar
        XCTAssertTrue(app.tabBars.buttons["Home"].exists)
        XCTAssertTrue(app.tabBars.buttons["Analytics"].exists)
        XCTAssertTrue(app.tabBars.buttons["History"].exists)
        XCTAssertTrue(app.tabBars.buttons["Settings"].exists)
        
        // Verify mood slider
        XCTAssertTrue(app.sliders["Mood"].exists)
        
        // Verify recent entries
        XCTAssertTrue(app.tables.staticTexts["Recent Entries"].exists)
    }
    
    func testAnalyticsTabLayout() {
        let app = XCUIApplication()
        app.launch()
        
        // Navigate to Analytics tab
        app.tabBars.buttons["Analytics"].tap()
        
        // Verify analytics elements
        XCTAssertTrue(app.pickers["Time Range"].exists)
        XCTAssertTrue(app.charts.firstMatch.exists)
    }
    
    func testHistoryTabLayout() {
        let app = XCUIApplication()
        app.launch()
        
        // Navigate to History tab
        app.tabBars.buttons["History"].tap()
        
        // Verify history elements
        XCTAssertTrue(app.pickers["Mood Filter"].exists)
        XCTAssertTrue(app.pickers["Date Range"].exists)
        XCTAssertTrue(app.searchFields["Search notes..."].exists)
    }
    
    func testSettingsTabLayout() {
        let app = XCUIApplication()
        app.launch()
        
        // Navigate to Settings tab
        app.tabBars.buttons["Settings"].tap()
        
        // Verify settings elements
        XCTAssertTrue(app.tables.staticTexts["Appearance"].exists)
        XCTAssertTrue(app.tables.staticTexts["Reminders"].exists)
        XCTAssertTrue(app.tables.staticTexts["Data Export"].exists)
        XCTAssertTrue(app.tables.staticTexts["Privacy"].exists)
    }
    
    // MARK: - iPad Specific Tests
    func testiPadLayout() {
        let app = XCUIApplication()
        app.launch()
        
        // Verify split view support
        XCTAssertTrue(app.splitViews.exists)
        
        // Verify adaptive layout
        app.tabBars.buttons["History"].tap()
        XCTAssertTrue(app.navigationBars["History"].exists)
    }
}
