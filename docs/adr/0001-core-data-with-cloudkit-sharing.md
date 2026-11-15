# Core Data with CloudKit for persistence and sharing

Musicians must be able to live-share Songs, Parts and Collections with other people, sync across devices and cost nothing to run at any scale. We use Core Data with `NSPersistentCloudKitContainer` (private and shared CloudKit databases, CKShare for invitations) rather than SwiftData, because SwiftData can't share data with other users.

## Considered Options

- **SwiftData + CloudKit**: the most idiomatic fit for SwiftUI, but it has no CKShare support, so it can't do live sharing.
- **SQLiteData (Point-Free)**: works with `@Observable` and supports sharing, but adds a third-party dependency for the most locked-in layer of the app.
- **Firebase / Supabase**: running costs grow with users and users need accounts, which conflicts with the zero-running-cost goal.

## Consequences

- The data layer uses `NSManagedObject` (`ObservableObject`), which is an exception to the project's `@Observable` convention.
- Every attribute must be optional or have a default, there are no unique constraints, and once the schema is deployed to production it can only gain fields, never lose or rename them.
- Objects that relate to each other must live in the same store, so a relationship can't cross between private and shared data.
