import Foundation

struct Scenario: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let title: String
    let summary: String
    let systemContext: String
    let symbolName: String
}
