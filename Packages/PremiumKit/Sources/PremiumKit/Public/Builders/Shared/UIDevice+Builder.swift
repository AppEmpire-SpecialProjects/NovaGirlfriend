import UIKit

public extension UIDevice {
    static var isIpad: Bool {
        current.userInterfaceIdiom == .pad
    }
    
    static var isSe: Bool {
        UIScreen.main.bounds.height <= 667
    }
}
