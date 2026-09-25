import SwiftUI

struct AnimatedScaleButton<Label: View>: View {
    let isActive: Bool
    let duration: Double
    let scale: CGFloat
    let action: () -> Void
    @ViewBuilder let label: () -> Label

    @State private var isPulsing = false

    var body: some View {
        Button(action: action) {
            label()
        }
        .scaleEffect(isPulsing ? scale : 1.0)
        .onAppear { startPulse(isActive) }
        .onChange(of: isActive) { startPulse($0) }
        .onDisappear { startPulse(false) }
    }

    private func startPulse(_ active: Bool) {
        guard active else {
            withAnimation(.default) { isPulsing = false }
            return
        }
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}
