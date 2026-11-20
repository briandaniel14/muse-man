import CoreData

extension MuseManModel {
    static func entity(_ name: String, className: String, properties: [NSPropertyDescription]) -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = name
        entity.managedObjectClassName = className
        entity.properties = properties
        return entity
    }

    static func attribute(
        _ name: String,
        _ type: NSAttributeDescription.AttributeType,
        defaultValue: Any? = nil,
    ) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.type = type
        attribute.isOptional = true
        attribute.defaultValue = defaultValue
        return attribute
    }

    static func relationship(
        _ name: String,
        to destination: NSEntityDescription,
        toMany: Bool,
        deleteRule: NSDeleteRule = .nullifyDeleteRule,
    ) -> NSRelationshipDescription {
        let relationship = NSRelationshipDescription()
        relationship.name = name
        relationship.destinationEntity = destination
        relationship.minCount = 0
        relationship.maxCount = toMany ? 0 : 1
        relationship.isOptional = true
        relationship.isOrdered = false
        relationship.deleteRule = deleteRule
        return relationship
    }

    static func relate(_ forward: NSRelationshipDescription, inverse: NSRelationshipDescription) {
        forward.inverseRelationship = inverse
        inverse.inverseRelationship = forward
        inverse.destinationEntity?.properties.append(forward)
        forward.destinationEntity?.properties.append(inverse)
    }
}
