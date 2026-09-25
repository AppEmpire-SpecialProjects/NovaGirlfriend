import SwiftUI
import WebKit

public struct WebBannerView: UIViewRepresentable {
    let url: URL
    
    public init(url: URL) {
        self.url = url
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }
    
    public func updateUIView(_ webView: WKWebView, context: Context) {}
}

public struct WebBannerModifier: ViewModifier {
    @ObservedObject private var viewModel = WebBannerViewModel.shared
    
    public func body(content: Content) -> some View {
        content
            .task {
                await viewModel.load()
            }
            .overlay {
                if viewModel.isShow, let url = viewModel.url {
                    WebBannerView(url: url)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea()
                }
            }
    }
}

public extension View {
    func webBannerOverlay() -> some View {
        modifier(WebBannerModifier())
    }
}
