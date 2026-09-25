import SwiftUI

struct SplashView: UIViewControllerRepresentable {
  func makeUIViewController(context: Context) -> UIViewController {
    UIStoryboard(name: "Launch Screen", bundle: nil).instantiateInitialViewController()!
  }

  func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

#Preview {
  SplashView()
    .ignoresSafeArea()
}
