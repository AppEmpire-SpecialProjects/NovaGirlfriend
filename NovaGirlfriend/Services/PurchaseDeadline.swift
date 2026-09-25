import Foundation

@MainActor
enum PurchaseDeadline {
  struct Timeout: LocalizedError {
    var errorDescription: String? {
      "Plans are unavailable. Check your connection and try again."
    }
  }

  static func run<Value: Sendable>(
    seconds: TimeInterval,
    operation: @escaping @MainActor () async throws -> Value
  ) async throws -> Value {
    let pending = Pending()
    return try await withTaskCancellationHandler {
      try Task.checkCancellation()
      return try await withCheckedThrowingContinuation {
        (continuation: CheckedContinuation<Value, Error>) in
        pending.onCancel = {
          pending.finish { continuation.resume(throwing: CancellationError()) }
        }
        pending.operation = Task { @MainActor in
          do {
            let value = try await operation()
            pending.finish { continuation.resume(returning: value) }
          } catch {
            pending.finish { continuation.resume(throwing: error) }
          }
        }
        pending.timer = Task { @MainActor in
          do {
            try await Task.sleep(for: .seconds(seconds))
            pending.finish { continuation.resume(throwing: Timeout()) }
          } catch {
            // The operation or its caller already completed this request.
          }
        }
      }
    } onCancel: {
      Task { @MainActor in
        pending.onCancel?()
      }
    }
  }

  @MainActor
  private final class Pending {
    private var isFinished = false
    var onCancel: (() -> Void)?
    var operation: Task<Void, Never>?
    var timer: Task<Void, Never>?

    func finish(_ completion: () -> Void) {
      guard !isFinished else { return }
      isFinished = true
      onCancel = nil
      operation?.cancel()
      timer?.cancel()
      operation = nil
      timer = nil
      completion()
    }
  }
}
