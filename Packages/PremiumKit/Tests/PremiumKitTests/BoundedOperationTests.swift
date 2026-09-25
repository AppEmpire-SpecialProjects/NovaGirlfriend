import XCTest
@testable import PremiumKit

final class BoundedOperationTests: XCTestCase {
    private actor Gate {
        private var continuation: CheckedContinuation<Int, Never>?
        private var waiting = false

        func wait() async -> Int {
            await withCheckedContinuation {
                continuation = $0
                waiting = true
            }
        }

        func isWaiting() -> Bool { waiting }

        func release(_ value: Int) {
            continuation?.resume(returning: value)
            continuation = nil
        }
    }

    private func waitUntilStarted(_ gate: Gate) async throws {
        for _ in 0..<200 {
            if await gate.isWaiting() { return }
            try await Task.sleep(nanoseconds: 1_000_000)
        }
        XCTFail("Operation never started")
    }

    func testNonCooperativeOperationTimesOutAndLateCompletionIsIgnored() async throws {
        let gate = Gate()
        let start = Date()
        do {
            _ = try await BoundedOperation.run(seconds: 0.03) { await gate.wait() }
            XCTFail("Expected timeout")
        } catch is BoundedOperation.TimedOut {
            XCTAssertLessThan(Date().timeIntervalSince(start), 0.5)
        }
        // The continuation ignores cancellation and resumes after timeout.
        // A second resume of the race's continuation would crash this test.
        await gate.release(42)
        let retry = try await BoundedOperation.run(seconds: 1) { 7 }
        XCTAssertEqual(retry, 7)
    }

    func testCancellationReturnsWithoutWaitingForOperation() async throws {
        let gate = Gate()
        let task = Task {
            try await BoundedOperation.run(seconds: 10) { await gate.wait() }
        }
        try await waitUntilStarted(gate)
        let start = Date()
        task.cancel()
        do {
            _ = try await task.value
            XCTFail("Expected cancellation")
        } catch is CancellationError {
            XCTAssertLessThan(Date().timeIntervalSince(start), 0.5)
        }
        await gate.release(42)
    }

    func testAlreadyCancelledCallerDoesNotStartWork() async {
        let task = Task {
            withUnsafeCurrentTask { $0?.cancel() }
            do {
                _ = try await BoundedOperation.run(seconds: 1) {
                    XCTFail("Cancelled operation must not start")
                    return 1
                }
                XCTFail("Expected cancellation")
            } catch {
                XCTAssertTrue(error is CancellationError)
            }
        }
        await task.value
    }

    func testSuccessErrorAndFastRacesResumeOnce() async throws {
        struct Expected: Error {}
        do {
            _ = try await BoundedOperation.run(seconds: 1) { throw Expected() }
            XCTFail("Expected operation error")
        } catch {
            XCTAssertTrue(error is Expected)
        }
        for _ in 0..<200 {
            do {
                let value = try await BoundedOperation.run(seconds: 0) { 12 }
                XCTAssertEqual(value, 12)
            } catch {
                XCTAssertTrue(error is BoundedOperation.TimedOut)
            }
        }
    }

    @MainActor
    func testReplacementRejectsLateResultAndIDsAreIndependent() async throws {
        let loads = LatestLoadTasks<String>()
        let gate = Gate()
        var values: [String: Int] = [:]
        let old = Task {
            await loads.run(for: "main") {
                await gate.wait()
            } apply: {
                values["main"] = $0
            }
        }
        try await waitUntilStarted(gate)
        await loads.run(for: "onboarding", operation: { 8 }, apply: { values["onboarding"] = $0 })
        await loads.run(for: "main", operation: { 9 }, apply: { values["main"] = $0 })
        await gate.release(1)
        await old.value
        XCTAssertEqual(values, ["main": 9, "onboarding": 8])
        await loads.run(for: "main", operation: { 10 }, apply: { values["main"] = $0 })
        XCTAssertEqual(values["main"], 10)
    }

    @MainActor
    func testCancelledLoadDoesNotPublishAndCanRetry() async throws {
        let loads = LatestLoadTasks<String>()
        let gate = Gate()
        var values: [Int] = []
        let load = Task {
            await loads.run(for: "main") {
                try? await BoundedOperation.run(seconds: 10) { await gate.wait() }
            } apply: { value in
                if let value { values.append(value) }
            }
        }
        try await waitUntilStarted(gate)
        load.cancel()
        await load.value
        XCTAssertTrue(values.isEmpty)
        await loads.run(for: "main", operation: { 2 }, apply: { values.append($0) })
        await gate.release(1)
        XCTAssertEqual(values, [2])
    }
}
