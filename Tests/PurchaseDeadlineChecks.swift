import Foundation

@main
@MainActor
struct PurchaseDeadlineChecks {
  private enum Failure: Error { case expected }

  @MainActor
  private final class SuspendedOperation {
    var continuation: CheckedContinuation<Int, Never>?

    func wait() async -> Int {
      await withCheckedContinuation { continuation = $0 }
    }

    func finish(_ value: Int) {
      continuation?.resume(returning: value)
      continuation = nil
    }
  }

  static func main() async throws {
    let immediate = try await PurchaseDeadline.run(seconds: 1) { 42 }
    precondition(immediate == 42)

    do {
      _ = try await PurchaseDeadline.run(seconds: 1) { () -> Int in
        throw Failure.expected
      }
      preconditionFailure("An operation error must propagate")
    } catch Failure.expected {}

    let stalled = SuspendedOperation()
    let start = ContinuousClock.now
    do {
      _ = try await PurchaseDeadline.run(seconds: 0.04) { await stalled.wait() }
      preconditionFailure("An uncancellable operation must time out")
    } catch is PurchaseDeadline.Timeout {}
    precondition(start.duration(to: .now) < .seconds(1))
    precondition(stalled.continuation != nil, "Timeout must not await the operation")
    stalled.finish(99)
    await Task.yield()

    let cancelled = SuspendedOperation()
    let task = Task {
      try await PurchaseDeadline.run(seconds: 5) { await cancelled.wait() }
    }
    while cancelled.continuation == nil { await Task.yield() }
    let cancellationStart = ContinuousClock.now
    task.cancel()
    do {
      _ = try await task.value
      preconditionFailure("Caller cancellation must propagate")
    } catch is CancellationError {}
    precondition(cancellationStart.duration(to: .now) < .seconds(1))
    cancelled.finish(100)
    await Task.yield()

    for _ in 0..<50 {
      let earlyCancellation = Task {
        try await PurchaseDeadline.run(seconds: 1) {
          try await Task.sleep(for: .milliseconds(50))
          return 1
        }
      }
      earlyCancellation.cancel()
      do {
        _ = try await earlyCancellation.value
        preconditionFailure("Cancellation before registration must propagate")
      } catch is CancellationError {}
    }

    for _ in 0..<50 {
      let value = try await PurchaseDeadline.run(seconds: 1) { 7 }
      precondition(value == 7, "Retry must be independent of previous completions")
    }
    print("PASS: success, errors, noncooperative timeout, cancellation, late completion, retry")
  }
}
