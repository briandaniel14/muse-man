import CoreData

struct Review {
    let day: Date
    let rating: Rating
}

public extension PracticeLibrary {
    func makeUnratedPartsDueToday() throws {
        let request = NSFetchRequest<PartObject>(entityName: "Part")
        request.predicate = NSPredicate(format: "status != %d", Part.Status.wantToLearn.rawValue)
        for part in fetch(request) {
            if let identifier = part.identifier, reviews(of: identifier).isEmpty {
                part.dueDate = today
            }
        }
        try save()
    }
}

extension PracticeLibrary {
    func reschedule(_ part: PartObject) {
        guard let identifier = part.identifier else {
            return
        }
        part.dueDate = dueDate(after: reviews(of: identifier)) ?? today
    }

    func reviews(of partIdentifier: UUID) -> [Review] {
        let request = NSFetchRequest<PracticeEntryObject>(entityName: "PracticeEntry")
        request.predicate = NSPredicate(format: "partID == %@", partIdentifier as NSUUID)
        let entries = fetch(request).sorted { order($0) < order($1) }
        var reviews: [Review] = []
        for entry in entries {
            guard let start = entry.session?.startDate, let rating = entry.savedRating else {
                continue
            }
            let day = Calendar.current.startOfDay(for: start)
            if reviews.last?.day == day {
                reviews.removeLast()
            }
            reviews.append(Review(day: day, rating: rating))
        }
        return reviews
    }

    private func order(_ entry: PracticeEntryObject) -> (Date, Date) {
        (entry.session?.startDate ?? .distantPast, entry.date ?? .distantPast)
    }

    func dueDate(after reviews: [Review]) -> Date? {
        guard let first = reviews.first, let last = reviews.last else {
            return nil
        }
        var memory = FSRS(rating: first.rating)
        for (previous, review) in zip(reviews, reviews.dropFirst()) {
            let elapsed = Calendar.current.dateComponents([.day], from: previous.day, to: review.day).day ?? 0
            memory.review(review.rating, after: elapsed)
        }
        return Calendar.current.date(byAdding: .day, value: memory.interval, to: last.day)
    }
}
