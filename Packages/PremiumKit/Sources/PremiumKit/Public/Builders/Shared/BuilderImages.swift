import SwiftUI

public struct AdaptiveResources: @unchecked Sendable {
    public let iphone: Image
    public let iphoneS: Image
    public let ipadL: Image

    public init(
        iphone: Image,
        iphoneS: Image? = nil,
        ipadL: Image? = nil
    ) {
        self.iphone = iphone
        self.iphoneS = iphoneS ?? iphone
        self.ipadL = ipadL ?? iphone
    }
}
