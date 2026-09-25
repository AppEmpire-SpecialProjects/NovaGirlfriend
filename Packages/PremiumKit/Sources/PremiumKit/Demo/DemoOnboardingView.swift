import SwiftUI

public struct DemoOnboardingView: View {
    let onComplete: () -> Void
    
    @State private var isLoading = false
    @State private var isTrialEnabled = false
    @State private var isShowAlert = false
    @State private var isShowCancelledAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    @State private var step: Onboarding = .page1
    
    @ObservedObject private var premiumService = Premium.shared
    
    private var products: [PremiumProduct] {
        premiumService.availablePaywall.products
    }
    
    private var selectedProduct: PremiumProduct? {
        if products.count == 1 {
            return products.first
        }
        return isTrialEnabled ? products.first : products.last
    }
    
    public init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }
    
    public var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                HStack(spacing: 4) {
                    ForEach(1...4, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 100)
                            .fill(index <= step.rawValue + 1 ? .pink : .pink.opacity(0.2))
                            .frame(width: index == step.rawValue + 1 ? 24 : 6, height: 6)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: step.rawValue)
                
                titleSection(text: getTitle())

                VStack(spacing: 0) {
                    subtitle(text: getSubtitle())
                    
                    if step == .paywall {
                        limittedButton(text: premiumService.availablePaywall.buttons.limited)
                    }
                }
                
                VStack(spacing: 6) {
                    switch premiumService.availableProducts {
                    case .withTrial, .noTrial:
                        EmptyView()
                    case .both:
                        messageSection
                    }
                    
                    nextButton
                    links
                }
            }
            .padding()
            .padding(.bottom, 10)
        }
        .animation(.easeInOut(duration: 0.2), value: step)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .blur(radius: isLoading ? 4 : 0)
        .overlay {
            ProgressView()
                .opacity(isLoading ? 1 : 0)
        }
        .alert(isPresented: $isShowAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage))
        }
        .alert(Text(alertMessage), isPresented: $isShowCancelledAlert) {
            Button(L10n.Alert.cancel, role: .cancel) { }
            Button(L10n.Alert.retry) {
                guard let product = selectedProduct else { return }
                Task {
                    isLoading = true
                    let result = await premiumService.purchase(product)
                    handleResult(result)
                    isLoading = false
                }
            }
        } message: {
            Text(L10n.Alert.retryMessage)
        }
        .onChange(of: step) { newValue in
            if newValue == .paywall {
                premiumService.paywallShown()
            }
        }
        .onChange(of: premiumService.availableProducts) { newValue in
            switch newValue {
            case .both:
                break
            case .withTrial:
                isTrialEnabled = true
            case .noTrial:
                isTrialEnabled = false
            }
        }
    }
    
    private var links: some View {
        HStack(spacing: 10) {
            Button(action: {
                
            }, label: {
                Text("Terms of use")
            })
            
            Button(action: {
                
            }, label: {
                Text("Privacy Policy")
            })

            Button(action: {
                restoreTapped()
            }, label: {
                Text("Restore")
            })
        }
        .font(.system(size: 13, weight: .regular))
        .foregroundColor(.gray)
        .frame(height: 20)
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private func titleSection(text: String) -> some View {
        Text(text)
            .font(.system(size: 26, weight: .heavy))
            .foregroundStyle(.black)
            .multilineTextAlignment(.center)
    }
    
    private func subtitle(text: String) -> some View {
        Text(text)
            .frame(maxWidth: .infinity, alignment: .top)
            .font(.system(size: 15, weight: .regular))
            .foregroundStyle(.gray)
            .multilineTextAlignment(.center)
    }
    
    private func limittedButton(text: String) -> some View {
        Button {
            onComplete()
        } label: {
            Text(text)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
        }
    }
    
    @ViewBuilder
    private var messageSection: some View {
        Text(getMessage())
            .frame(height: 48)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.system(size: 15, weight: .regular))
            .foregroundStyle(.black)
            .overlay(alignment: .trailing) {
                Toggle(isTrialEnabled ? "" : "", isOn: $isTrialEnabled)
                    .opacity(step == .paywall ? 1 : 0)
                    .tint(.pink)
            }
            .padding(.horizontal, 16)
            .background(.secondary)
            .cornerRadius(100)
    }
    
    private var nextButton: some View {
        Button(action: {
            nextTapped()
        }, label: {
            HStack {
                Text(getButtonTitle())
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .padding()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(.pink)
            .cornerRadius(100)
        })
    }
    
    private func nextTapped() {
        if step == .paywall {
            purchaseTapped()
        } else if let nextStep = step.next {
            step = nextStep
        }
    }
    
    private func getTitle() -> String {
        if step != .paywall {
            return step.inputModel().title
        } else {
            return premiumService.availablePaywall.title
        }
    }

    private func getSubtitle() -> String {
        if step != .paywall {
            return step.inputModel().subtitle
        } else {
            return selectedProduct?.paywallSubtitle ?? ""
        }
    }
    
    private func getMessage() -> String {
        if step != .paywall {
            return step.inputModel().message
        } else {
            return selectedProduct?.message ?? ""
        }
    }
    
    private var buttonTitle: String {
        guard let product = selectedProduct else {
            return ""
        }
        return premiumService.availablePaywall.buttonTitle(for: product)
    }
    
    private func getButtonTitle() -> String {
        if step != .paywall {
            step.inputModel().buttonTitle
        } else {
            buttonTitle
        }
    }
    
    private func purchaseTapped() {
        guard let product = selectedProduct else { return }
        Task {
            isLoading = true
            defer { isLoading = false }
            let result = await premiumService.purchase(product)
            handleResult(result)
        }
    }
    
    private func restoreTapped() {
        Task(priority: .userInitiated) { @MainActor in
            isLoading = true
            defer { isLoading = false }
            
            Task {
                let result = await premiumService.restore()
                handleResult(result)
            }
        }
    }
    
    @MainActor
    private func handleResult(_ result: Result<Void, PremiumError>) {
        switch result {
        case .success:
            onComplete()
        case .failure(let error):
            alertMessage = error.localizedDescription
            if case .cancelled = error {
                isShowCancelledAlert = true
            } else {
                alertTitle = L10n.Alert.error
                isShowAlert = true
            }
        }
    }
}
