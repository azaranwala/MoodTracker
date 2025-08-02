import CoreData
import Foundation

/// Manages Core Data stack and provides CRUD operations
final class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        print("🚀 Initializing PersistenceController")
        
        // Try to load the model from the main bundle
        let modelName = "MoodTracker"
        
        // Check if the model exists in the main bundle
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            let message = "❌ Could not find \(modelName).xcdatamodeld. Please make sure:\n" +
            "1. The Core Data model file is added to your target\n" +
            "2. The file is named exactly '\(modelName).xcdatamodeld'\n" +
            "3. The file is included in the app's target membership"
            fatalError(message)
        }
        
        // Try to load the model
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            let message = "❌ Failed to load Core Data model from \(modelURL). " +
            "Please check that the model file is valid."
            fatalError(message)
        }
        
        // Initialize the container with the model
        container = NSPersistentContainer(name: modelName, managedObjectModel: model)
        
        // Configure the container
        if inMemory {
            print("📦 Using in-memory store")
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            if let url = container.persistentStoreDescriptions.first?.url {
                print("💾 Using persistent store at: \(url)")
            } else {
                print("⚠️ Warning: Could not determine persistent store URL")
            }
        }
        
        // Load the persistent stores
        print("🔍 Loading persistent stores...")
        container.loadPersistentStores { [weak self] description, error in
            if let error = error as NSError? {
                let message = "❌ Failed to load Core Data stack: \(error), \(error.userInfo)\n" +
                "This could be due to a corrupted database or schema mismatch. " +
                "You may need to delete and reinstall the app."
                fatalError(message)
            }
            
            print("✅ Successfully loaded persistent store")
            
            // Configure the view context
            self?.configureViewContext()
        }
    }
    
    private func configureViewContext() {
        // Enable automatic merging of changes from parent
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // Configure merge policy
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        // Print some debug info
        print("📊 Current merge policy: \(container.viewContext.mergePolicy)")
        print("🔄 Automatically merges changes from parent: \(container.viewContext.automaticallyMergesChangesFromParent)")
    }
    
    // MARK: - Preview Support
    
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        // Create sample data for preview
        for i in 0..<10 {
            let newItem = NSEntityDescription.insertNewObject(forEntityName: "MoodEntry", into: viewContext)
            newItem.setValue(Date().addingTimeInterval(TimeInterval(-86400 * i)), forKey: "dateTime")
            newItem.setValue(Int16.random(in: 1...10), forKey: "moodValue")
            newItem.setValue(["😢", "😞", "😐", "🙂", "😊", "😄", "🤩"].randomElement()!, forKey: "emoji")
            newItem.setValue("Sample note \(i)", forKey: "note")
        }
        
        do {
            try viewContext.save()
            print("✅ Created preview data")
        } catch {
            let nsError = error as NSError
            print("❌ Error creating preview data: \(nsError), \(nsError.userInfo)")
        }
        
        return controller
    }()
}

// MARK: - Core Data Saving Support

extension PersistenceController {
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("💾 Successfully saved context")
            } catch {
                let nsError = error as NSError
                print("❌ Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

// MARK: - Core Data Model Extensions
extension NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        return NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: self))
    }
}
