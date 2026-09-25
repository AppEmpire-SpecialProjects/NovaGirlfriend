import SwiftUI

extension View {
    public func taskOnce(priority: TaskPriority = .userInitiated, _ action: @escaping @Sendable () async -> Void) -> some View {
        modifier(TaskOnceModifier(priority: priority, action: action))
    }
}

private struct TaskOnceModifier: ViewModifier {
    let priority: TaskPriority
    let action: @Sendable () async -> Void
    
    @State private var hasRun = false
    
    func body(content: Content) -> some View {
        content
            .task(priority: priority) {
                guard !hasRun else { return }
                hasRun = true
                await action()
            }
    }
}
