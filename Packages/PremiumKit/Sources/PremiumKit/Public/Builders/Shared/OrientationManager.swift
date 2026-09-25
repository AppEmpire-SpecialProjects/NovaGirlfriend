import SwiftUI
import Combine

@MainActor
public final class OrientationManager: ObservableObject {
    
    public static let shared = OrientationManager()
    
    @Published public private(set) var isLandscape: Bool
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        let orientation = UIDevice.current.orientation
        isLandscape = orientation.isLandscape || (!orientation.isPortrait && UIScreen.main.bounds.width > UIScreen.main.bounds.height)
        
        NotificationCenter.default
            .publisher(for: UIDevice.orientationDidChangeNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                let o = UIDevice.current.orientation
                self?.isLandscape = o.isLandscape || (!o.isPortrait && UIScreen.main.bounds.width > UIScreen.main.bounds.height)
            }
            .store(in: &cancellables)
    }
}
