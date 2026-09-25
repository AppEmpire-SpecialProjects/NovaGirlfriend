import SwiftUI

public struct DemoPaywallView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var premiumService = Premium.shared
    
    @State private var selectedIndex = 0
    @State private var isLoading = false
    @State private var isShowAlert = false
    @State private var isShowCancelledAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    private var products: [PremiumProduct] {
        premiumService.availablePaywall.products
    }
    
    private var selectedProduct: PremiumProduct? {
        products[safe: selectedIndex]
    }
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Spacer()
                    subtitle(getSubtitle())
                    title(getTitle())
                    offers
                    nextButton
                    links
                }
                .padding(.horizontal)
            }
            .onAppear {
                premiumService.paywallShown()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.system(size: 12, weight: .regular))
                    })
                }
            }
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
        }
    }
    
    private var links: some View {
        HStack(spacing: 10) {
            Button(action: {
            }, label: {
                Text("Terms of use")
            })
            
            RoundedRectangle(cornerRadius: 100)
                .fill(.gray)
                .frame(width: 1, height: 20)
            
            Button(action: {
            }, label: {
                Text("Privacy Policy")
            })
            
            RoundedRectangle(cornerRadius: 100)
                .fill(.gray)
                .frame(width: 1, height: 20)
            
            Button(action: {
                Task {
                    let result = await premiumService.restore()
                    handleResult(result)
                }
            }, label: {
                Text("Restore")
            })
        }
        .font(.system(size: 13, weight: .regular))
        .foregroundColor(.gray)
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: 20)
    }
    
    private var buttonTitle: String {
        guard let product = selectedProduct else {
            return ""
        }
        return premiumService.availablePaywall.buttonTitle(for: product)
    }
    
    private var nextButton: some View {
        Button(action: {
            guard let product = selectedProduct else { return }
            Task {
                isLoading = true
                let result = await premiumService.purchase(product)
                handleResult(result)
                isLoading = false
            }
        }, label: {
            Text(buttonTitle)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 100)
                        .fill(.pink)
                )
        })
        .disabled(isLoading)
    }
    
    private var offers: some View {
        VStack(spacing: 4) {
            ForEach(Array(products.enumerated()), id: \.offset) { offset, offer in
                Button {
                    selectedIndex = offset
                    guard let product = selectedProduct else { return }
                    Task {
                        isLoading = true
                        let result = await premiumService.purchase(product)
                        handleResult(result)
                        isLoading = false
                    }
                } label: {
                    labelOffer(from: offer, index: offset)
                }
            }
        }
    }
    
    @ViewBuilder
    private func title(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 28, weight: .bold))
            .foregroundStyle(.black)
    }
    
    @ViewBuilder
    private func subtitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .regular))
            .foregroundStyle(.black.opacity(0.6))
    }
    
    @ViewBuilder
    private func message(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .regular))
            .foregroundStyle(.black.opacity(0.6))
    }
    
    @ViewBuilder
    private func labelOffer(from offer: PremiumProduct, index: Int) -> some View {
        let isSelected = selectedIndex == index
        
        HStack(spacing: 4) {
            VStack(alignment: .leading, spacing: 4) {
                Text(offer.hasTrial ? L10n.Product.trialTitle : offer.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)
                
                Text(offer.pricePerWeek)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(isSelected ? .black.opacity(0.8) : .black.opacity(0.6))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(offer.pricePerPeriod)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.black)
        }
        .padding(.horizontal)
        .frame(height: 54)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? .pink : .gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
        )
    }
    
    private func getTitle() -> String {
        premiumService.availablePaywall.title
    }
    
    private func getSubtitle() -> String {
        selectedProduct?.paywallSubtitle ?? ""
    }
    
    @MainActor
    private func handleResult(_ result: Result<Void, PremiumError>) {
        switch result {
        case .success:
            dismiss()
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
