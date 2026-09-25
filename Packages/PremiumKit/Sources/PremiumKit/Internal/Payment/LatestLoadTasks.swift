import Foundation

/// Same-ID requests replace/cancel their predecessor; different IDs never cancel
/// each other. Only the latest live request may publish a returned value.
@MainActor
final class LatestLoadTasks<Key: Hashable> {
    private struct Entry {
        let token: UUID
        let task: Task<Void, Never>
    }

    private var entries: [Key: Entry] = [:]

    func run<Value>(
        for key: Key,
        operation: @escaping @MainActor () async -> Value,
        apply: @escaping @MainActor (Value) -> Void
    ) async {
        guard !Task.isCancelled else { return }
        entries[key]?.task.cancel()
        let token = UUID()
        let task = Task { @MainActor in
            guard !Task.isCancelled else { return }
            let value = await operation()
            guard !Task.isCancelled, self.entries[key]?.token == token else { return }
            apply(value)
        }
        entries[key] = Entry(token: token, task: task)
        await withTaskCancellationHandler {
            await task.value
        } onCancel: {
            task.cancel()
        }
        if entries[key]?.token == token {
            entries[key] = nil
        }
    }
}
