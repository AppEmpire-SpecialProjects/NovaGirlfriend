import Foundation

/// Unlike a task group, this race does not wait for a losing, non-cooperative
/// operation. Operations must return values, not mutate published payment state.
enum BoundedOperation {
    struct TimedOut: Error {}

    static func run<Value>(
        seconds: Double,
        operation: @escaping @Sendable () async throws -> Value
    ) async throws -> Value {
        let race = Race<Value>()
        return try await withTaskCancellationHandler {
            try Task.checkCancellation()
            return try await withCheckedThrowingContinuation { continuation in
                guard race.install(continuation) else { return }
                let worker = Task {
                    do {
                        try Task.checkCancellation()
                        race.finish(.success(try await operation()))
                    } catch {
                        race.finish(.failure(error))
                    }
                }
                let timer = Task {
                    do {
                        try await Task.sleep(nanoseconds: UInt64(max(0, seconds) * 1_000_000_000))
                        race.finish(.failure(TimedOut()))
                    } catch {
                        // The winning operation or caller cancelled the timer.
                    }
                }
                race.register(worker: worker, timer: timer)
            }
        } onCancel: {
            race.finish(.failure(CancellationError()))
        }
    }

    /// Cancellation can arrive before continuation/task registration. Keep the
    /// winning result until installation and cancel late registrations as well.
    private final class Race<Value>: @unchecked Sendable {
        private let lock = NSLock()
        private var result: Result<Value, Error>?
        private var continuation: CheckedContinuation<Value, Error>?
        private var worker: Task<Void, Never>?
        private var timer: Task<Void, Never>?

        func install(_ continuation: CheckedContinuation<Value, Error>) -> Bool {
            lock.lock()
            if let result {
                lock.unlock()
                continuation.resume(with: result)
                return false
            }
            self.continuation = continuation
            lock.unlock()
            return true
        }

        func register(worker: Task<Void, Never>, timer: Task<Void, Never>) {
            lock.lock()
            let finished = result != nil
            if !finished {
                self.worker = worker
                self.timer = timer
            }
            lock.unlock()
            if finished {
                worker.cancel()
                timer.cancel()
            }
        }

        func finish(_ result: Result<Value, Error>) {
            lock.lock()
            guard self.result == nil else {
                lock.unlock()
                return
            }
            self.result = result
            let continuation = self.continuation
            let worker = self.worker
            let timer = self.timer
            self.continuation = nil
            self.worker = nil
            self.timer = nil
            lock.unlock()

            worker?.cancel()
            timer?.cancel()
            continuation?.resume(with: result)
        }
    }
}
