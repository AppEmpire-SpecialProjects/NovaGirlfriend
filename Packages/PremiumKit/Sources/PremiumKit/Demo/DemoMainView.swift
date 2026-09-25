import SwiftUI

public struct DemoMainView: View {
    @ObservedObject private var premiumService = Premium.shared
    
    public init() {}
    public var body: some View {
        VStack {
            Text("Main flow")
            if premiumService.isPremium {
                Text("You are premium user")
            } else {
                Button("ShowPaywall") {
                    premiumService.isShowingPaywall = true
                }
            }
        }
    }
}
