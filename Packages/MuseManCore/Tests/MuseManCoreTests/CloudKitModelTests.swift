import CoreData
import MuseManCore
import Testing

struct CloudKitModelTests {
    let entities = PersistentStore.container().managedObjectModel.entities

    @Test func `every attribute is optional or has a default`() {
        let violations = entities.flatMap { entity in
            entity.attributesByName.values
                .filter { !$0.isOptional && $0.defaultValue == nil }
                .map { "\(entity.name ?? "?").\($0.name)" }
        }
        #expect(violations == [])
    }

    @Test func `every relationship is optional, unordered and has an inverse`() {
        let violations = entities.flatMap { entity in
            entity.relationshipsByName.values
                .filter { !$0.isOptional || $0.isOrdered || $0.inverseRelationship == nil }
                .map { "\(entity.name ?? "?").\($0.name)" }
        }
        #expect(violations == [])
    }

    @Test func `no relationship denies deletion`() {
        let violations = entities.flatMap { entity in
            entity.relationshipsByName.values
                .filter { $0.deleteRule == .denyDeleteRule }
                .map { "\(entity.name ?? "?").\($0.name)" }
        }
        #expect(violations == [])
    }

    @Test func `no entity has a uniqueness constraint`() {
        let violations = entities
            .filter { !$0.uniquenessConstraints.isEmpty }
            .map { $0.name ?? "?" }
        #expect(violations == [])
    }
}
