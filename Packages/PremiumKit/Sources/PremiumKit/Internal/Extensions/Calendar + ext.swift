import Foundation

extension Calendar {
    func daysGone(after days: Int, date: Date) -> Bool {
        if let diff = dateComponents([.day], from: date, to: Date()).day {
            return (diff >= days)
        } else {
            return false
        }
    }
    
    func days(from startDate: Date, to endDate: Date) -> Int {
        dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
}
