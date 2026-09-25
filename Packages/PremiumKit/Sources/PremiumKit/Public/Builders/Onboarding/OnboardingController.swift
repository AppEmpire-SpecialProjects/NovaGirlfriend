import Foundation

///Позволяет вызывать переход к следующему шагу онбординга извне
@MainActor
public final class OnboardingController: ObservableObject {
    var onNext: (() -> Void)?
    
    public init() {}
    
    public func next() {
        onNext?()
    }
}
