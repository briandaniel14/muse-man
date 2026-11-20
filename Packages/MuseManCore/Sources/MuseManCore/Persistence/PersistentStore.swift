import CloudKit
import CoreData

public enum PersistentStore {
    public static let cloudKitContainerIdentifier = "iCloud.com.briandaniel.museman"

    public static func app() -> NSPersistentCloudKitContainer {
        container(
            storeURL: NSPersistentContainer.defaultDirectoryURL().appending(path: "Private.sqlite"),
            cloudKitContainerIdentifier: cloudKitContainerIdentifier,
        )
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
