import CloudKit
import CoreData

public enum PersistentStore {
    public static let cloudKitContainerIdentifier = "iCloud.com.briandaniel.museman"

    public static func app() -> NSPersistentCloudKitContainer {
        #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("-scratchStore") {
                return scratch()
            }
        #endif
        let container = container(
            storeURL: NSPersistentContainer.defaultDirectoryURL().appending(path: "Private.sqlite"),
            cloudKitContainerIdentifier: cloudKitContainerIdentifier,
        )
        #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("-initializeCloudKitSchema") {
                try? container.initializeCloudKitSchema()
            }
        #endif
        return container
    }

    public static func scratch() -> NSPersistentCloudKitContainer {
        let container = container()
        SeedData.fill(container)
        return container
    }

    public static func container(
        storeURL: URL = URL(filePath: "/dev/null"),
        cloudKitContainerIdentifier: String? = nil,
    ) -> NSPersistentCloudKitContainer {
        let container = NSPersistentCloudKitContainer(name: "MuseMan", managedObjectModel: MuseManModel.shared)
        let description = NSPersistentStoreDescription(url: storeURL)
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        if let cloudKitContainerIdentifier {
            let options = NSPersistentCloudKitContainerOptions(containerIdentifier: cloudKitContainerIdentifier)
            options.databaseScope = .private
            description.cloudKitContainerOptions = options
        }
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("\(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return container
    }
}
