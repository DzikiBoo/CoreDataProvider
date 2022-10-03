import CoreData

public class CloudCoreDataProvider {
    public let context: NSManagedObjectContext
    public let coreData: CoreData
    
    public init(bundle: Bundle, containerName: String) {
        let coreData = CoreData(bundle: bundle, containerName: containerName)
        self.context = coreData.context
        self.coreData = coreData
    }
    
    public init(bundle: Bundle, for appGroup: String, containerName: String) {
        let coreData = CoreData(bundle: bundle, for: appGroup, containerName: containerName)
        self.context = coreData.context
        self.coreData = coreData
    }
}

public class CloudCoreData {
    let modelURL: URL
    let storeURL: URL?
    let containerName: String
    
    init(bundle: Bundle, containerName: String) {
        self.modelURL = bundle.url(forResource: containerName, withExtension: "momd")!
        self.storeURL = nil
        self.containerName = containerName
    }
    
    init(bundle: Bundle, for appGroup: String, containerName: String) {
        self.modelURL = bundle.url(forResource: containerName, withExtension: "momd")!
        self.storeURL = URL.storeURL(for: appGroup, databaseName: containerName)
        self.containerName = containerName
    }
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    open class PersistentContainer: NSPersistentCloudKitContainer {
    }
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        debugPrint("Store Init")
        
        

        let model = NSManagedObjectModel(contentsOf: modelURL)
        let container = PersistentContainer(name: containerName, managedObjectModel: model!)
        
        if let storeURL = storeURL {
            let description = NSPersistentStoreDescription()
            description.url = storeURL
            description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            container.persistentStoreDescriptions = [description]
        }
        
        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error as NSError? {
                debugPrint("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    public func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                debugPrint("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    public func deleteAllRecords(entityName: String) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
        } catch {
            debugPrint("error retrieving keys: \(error)")
        }
    }
}
