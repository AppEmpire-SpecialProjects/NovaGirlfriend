import Foundation

/// Relationship stages shared by every companion. Thresholds mirror the
/// reference product: 2 points per completed exchange, five named stages.
enum AffinityStage: String, CaseIterable, Codable, Sendable, Comparable {
  case stranger
  case warm
  case close
  case devoted
  case bound

  static let pointsPerExchange = 2

  var threshold: Int {
    switch self {
    case .stranger: 0
    case .warm: 60
    case .close: 180
    case .devoted: 400
    case .bound: 800
    }
  }

  var title: String {
    switch self {
    case .stranger: "Stranger"
    case .warm: "Warm"
    case .close: "Close"
    case .devoted: "Devoted"
    case .bound: "Bound"
    }
  }

  var detail: String {
    switch self {
    case .stranger: "You have just met. Every exchange brings you closer."
    case .warm: "The first sparks of a real connection."
    case .close: "You understand each other without many words."
    case .devoted: "A deep, trusted bond."
    case .bound: "An unbreakable bond. You have been through everything together."
    }
  }

  var symbolName: String {
    switch self {
    case .stranger: "hand.wave"
    case .warm: "sun.min"
    case .close: "heart"
    case .devoted: "heart.fill"
    case .bound: "infinity"
    }
  }

  var next: AffinityStage? {
    let ordered = Self.allCases
    guard let index = ordered.firstIndex(of: self), ordered.indices.contains(index + 1)
    else { return nil }
    return ordered[index + 1]
  }

  static func stage(forPoints points: Int) -> AffinityStage {
    allCases.reversed().first { points >= $0.threshold } ?? .stranger
  }

  /// Fraction (0...1) of the way from `stage` toward the next threshold.
  static func progress(from stage: AffinityStage, points: Int) -> Double {
    guard let next = stage.next else { return 1 }
    let span = next.threshold - stage.threshold
    precondition(span > 0)
    let covered = min(max(points - stage.threshold, 0), span)
    return Double(covered) / Double(span)
  }

  static func < (lhs: AffinityStage, rhs: AffinityStage) -> Bool {
    lhs.threshold < rhs.threshold
  }
}
