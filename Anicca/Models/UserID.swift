import Foundation

/// The one spelling of a Supabase user ID the app keeps: lowercase, as Postgres prints a `uuid`.
///
/// Swift's `UUID.uuidString` is UPPERCASE. Postgres doesn't care when it compares `uuid` columns,
/// but local check-ins are matched by a plain string compare in SwiftData, so a user with two
/// spellings would see their check-ins and free-tier count split in two.
enum UserID {
    static func normalized(_ id: String) -> String { id.lowercased() }
    static func normalized(_ id: UUID) -> String { normalized(id.uuidString) }
}
