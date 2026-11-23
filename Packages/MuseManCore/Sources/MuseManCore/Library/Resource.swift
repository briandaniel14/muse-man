import CoreData

public struct Resource: Identifiable, Hashable {
    public let id: NSManagedObjectID
    public var url: URL
    public var title: String?

    public var name: String {
        title ?? url.host(percentEncoded: false) ?? url.absoluteString
    }
}

extension Resource {
    init(_ object: ResourceObject) {
        id = object.objectID
        url = object.url.flatMap(URL.init(string:)) ?? URL(filePath: "/")
        title = object.title
    }
}
