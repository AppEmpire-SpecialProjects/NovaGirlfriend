import SwiftUI

extension ToolbarContent {
    @ToolbarContentBuilder
    func hideGlass() -> some ToolbarContent {
        if #available(iOS 26, *) {
            self.sharedBackgroundVisibility(.hidden)
        } else {
            self
        }
    }
}
