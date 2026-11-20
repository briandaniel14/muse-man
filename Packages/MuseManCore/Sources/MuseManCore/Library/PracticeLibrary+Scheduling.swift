import CoreData

struct Review {
    let day: Date
    let rating: Rating
}

extension PracticeLibrary {
    func reschedule(_ part: PartObject) {
        guard let identifier = part.identifier else {
            return
        }
        part.dueDate = dueDate(after: reviews(of: identifier)) ?? today
    }

    func reviews(of partID: UUID) -> [Review] {
        let request = NSFetchRequest<PracticeEntryObject>(entityName: "PracticeEntry")
        request.predicate = NSPredicate(format: "partID == %@", partID as NSUUID)
        let entries = fetch(request).sorted { order($0) < order($1) }
        var reviews: [Review] = []
        for entry in entries {
            guard let start = entry.session?.startDate else {
                continue
            }
            let day = Calendar.current.startOfDay(for: start)
            if reviews.last?.day == day {
                reviews.removeLast()
            }
            reviews.append(Review(day: day, rating: Rating(rawValue: entry.rating) ?? .good))
        }
        return reviews
    }

    private func order(_ entry: PracticeEntryObject) -> (Date, Date) {
        (entry.session?.startDate ?? .distantPast, entry.date ?? .distantPast)
    }

    func dueDate(after reviews: [Review]) -> Date? {
        reviews.last.flatMap { Calendar.current.date(byAdding: .day, value: 1, to: $0.day) }
    }
}
