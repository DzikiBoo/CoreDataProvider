import CoreData

public class CoreDataProvider {
    public let context: NSManagedObjectContext
    public let coreData: CoreData
    
    public init(bundle: Bundle, containerName: String, inMemory: Bool = false) {
        let coreData = CoreData(bundle: bundle, containerName: containerName, inMemory: inMemory)
        self.context = coreData.context
        self.coreData = coreData
    }
    
    public init(bundle: Bundle, for appGroup: String, containerName: String, inMemory: Bool = false) {
        let coreData = CoreData(bundle: bundle, for: appGroup, containerName: containerName)
        self.context = coreData.context
        self.coreData = coreData
    }
}

public class CoreData {
    let modelURL: URL
    let storeURL: URL?
    let containerName: String
    let inMemory: Bool
    
    init(bundle: Bundle, containerName: String, inMemory: Bool = false) {
        self.modelURL = bundle.url(forResource: containerName, withExtension: "momd")!
        self.storeURL = nil
        self.containerName = containerName
        self.inMemory = inMemory
    }
    
    init(bundle: Bundle, for appGroup: String, containerName: String, inMemory: Bool = false) {
        self.modelURL = bundle.url(forResource: containerName, withExtension: "momd")!
        self.storeURL = URL.storeURL(for: appGroup, databaseName: containerName)
        self.containerName = containerName
        self.inMemory = inMemory
    }
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    open class PersistentContainer: NSPersistentContainer {
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        debugPrint("Store Init")
        
        let model = NSManagedObjectModel(contentsOf: modelURL)
        let container = PersistentContainer(name: containerName, managedObjectModel: model!)
        
        if !inMemory, let storeURL = storeURL {
            let description = NSPersistentStoreDescription()
            description.url = storeURL
            container.persistentStoreDescriptions = [description]
        }
        
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
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
