import SwiftUI

public struct DemoTokensView: View {
    @ObservedObject private var premium = Premium.shared
    @State private var showConsumablePaywall = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 24) {
            Text("Tokens Demo")
                .font(.largeTitle.bold())
                .foregroundStyle(.black)
            
            VStack(spacing: 8) {
                Text("Your balance")
                    .font(.headline)
                    .foregroundStyle(.gray)
                
                Text("\(premium.tokens)")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundStyle(.black)
                
                Text("tokens")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            VStack(spacing: 8) {
                Text("Premium status: \(premium.isPremium ? "Has premium" : "No premium")")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
            
            VStack(spacing: 12) {
                Button {
                    useToken()
                } label: {
                    Text("Spend Token")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(RoundedRectangle(cornerRadius: 100).fill(.black))
                }
                
                if !premium.isPremium {
                    Button {
                        premium.isShowingPaywall = true
                    } label: {
                        Text("Show Subscription Paywall")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(RoundedRectangle(cornerRadius: 100).stroke(.black, lineWidth: 1))
                    }
                }
                
                if premium.isPremium && premium.tokens == 0 {
                    Button {
                        Task {
                            await premium.loadPaywall(.consumable)
                        }
                        showConsumablePaywall = true
                    } label: {
                        Text("Buy More Tokens")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(RoundedRectangle(cornerRadius: 100).stroke(.gray, lineWidth: 1))
                    }
                }
            }
            .padding(.horizontal, 32)
        }
        .padding()
        .taskOnce {
            await premium.loadPaywall(.main)
        }
        .fullScreenCover(isPresented: $showConsumablePaywall) {
            ConsumablePaywall(onDismiss: { showConsumablePaywall = false })
        }
        .fullScreenCover(isPresented: $premium.isShowingPaywall) {
            SubscriptionPaywall(onDismiss: { premium.isShowingPaywall = false })
        }
    }
    
    private func useToken() {
        if premium.tokens > 0 {
            premium.spendTokens()
        } else if premium.isPremium {
            Task {
                await premium.loadPaywall(.consumable)
            }
            showConsumablePaywall = true
        }
    }
}

struct SubscriptionPaywall: View {
    @ObservedObject private var premium = Premium.shared
    @State private var selectedIndex = 0
    @State private var isLoading = false
    @State private var isShowAlert = false
    @State private var isShowCancelledAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    let onDismiss: () -> Void
    
    private var products: [PremiumProduct] {
        premium.availablePaywall.products
    }
    
    private var selectedProduct: PremiumProduct? {
        products[safe: selectedIndex]
    }
    
    private var buttonTitle: String {
        guard let product = selectedProduct else { return "" }
        return premium.availablePaywall.buttonTitle(for: product)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Spacer()
                    subtitle
                    title
                    offers
                    nextButton
                }
                .padding(.horizontal)
            }
            .onAppear {
                premium.paywallShown()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: onDismiss) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .font(.system(size: 12, weight: .regular))
                    }
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
                Button("Cancel", role: .cancel) { }
                Button("Retry") {
                    guard let product = selectedProduct else { return }
                    purchase(product)
                }
            } message: {
                Text("Would you like to try again?")
            }
        }
    }
    
    private var title: some View {
        Text(premium.availablePaywall.title)
            .font(.system(size: 28, weight: .bold))
            .foregroundStyle(.black)
    }
    
    private var subtitle: some View {
        Text(selectedProduct?.paywallSubtitle ?? "")
            .font(.system(size: 13, weight: .regular))
            .foregroundStyle(.black.opacity(0.6))
    }
    
    private var offers: some View {
        VStack(spacing: 4) {
            ForEach(Array(products.enumerated()), id: \.offset) { offset, product in
                Button {
                    selectedIndex = offset
                    purchase(product)
                } label: {
                    labelOffer(from: product, index: offset)
                }
            }
        }
    }
    
    @ViewBuilder
    private func labelOffer(from product: PremiumProduct, index: Int) -> some View {
        let isSelected = selectedIndex == index
        
        HStack(spacing: 4) {
            VStack(alignment: .leading, spacing: 4) {
                Text(product.hasTrial ? L10n.Product.trialTitle : product.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)
                
                Text(consumableString(for: product))
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(isSelected ? .black.opacity(0.8) : .black.opacity(0.6))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(product.pricePerPeriod)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.black)
        }
        .padding(.horizontal)
        .frame(height: 54)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? .black : .gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
        )
    }
    
    private func consumableString(for product: PremiumProduct) -> String {
        guard let consumable = product.consumable, let unit = product.consumableUnit else {
            return product.pricePerWeek
        }
        let message = (product.message ?? "").isEmpty ? "" : "\(product.message!) + "
        let period = product.pricePerPeriod.components(separatedBy: "/").last ?? ""
        return "\(message)\(consumable) \(unit)/\(period)"
    }
    
    private var nextButton: some View {
        Button(action: {
            guard let product = selectedProduct else { return }
            purchase(product)
        }) {
            Text(buttonTitle)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(RoundedRectangle(cornerRadius: 100).fill(.black))
        }
        .disabled(isLoading)
    }
    
    private func purchase(_ product: PremiumProduct) {
        Task {
            isLoading = true
            let result = await premium.purchase(product)
            handleResult(result)
            isLoading = false
        }
    }
    
    @MainActor
    private func handleResult(_ result: Result<Void, PremiumError>) {
        switch result {
        case .success:
            onDismiss()
        case .failure(let error):
            alertMessage = error.localizedDescription
            if case .cancelled = error {
                isShowCancelledAlert = true
            } else {
                alertTitle = "Error"
                isShowAlert = true
            }
        }
    }
}

struct ConsumablePaywall: View {
    @ObservedObject private var premium = Premium.shared
    @State private var selectedIndex = 0
    @State private var isLoading = false
    @State private var isShowAlert = false
    @State private var isShowCancelledAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    let onDismiss: () -> Void
    
    private var products: [PremiumProduct] {
        premium.consumablePaywall.products
    }
    
    private var selectedProduct: PremiumProduct? {
        products[safe: selectedIndex]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Spacer()
                    subtitle
                    title
                    offers
                    nextButton
                }
                .padding(.horizontal)
            }
            .task {
                if premium.consumablePaywall.products.isEmpty {
                    await premium.loadPaywall(.consumable)
                }
                premium.paywallShown(.consumable)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: onDismiss) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .font(.system(size: 12, weight: .regular))
                    }
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
                Button("Cancel", role: .cancel) { }
                Button("Retry") {
                    guard let product = selectedProduct else { return }
                    purchase(product)
                }
            } message: {
                Text("Would you like to try again?")
            }
        }
    }
    
    private var title: some View {
        Text("Buy Tokens")
            .font(.system(size: 28, weight: .bold))
            .foregroundStyle(.black)
    }
    
    private var subtitle: some View {
        Text("One-time purchase")
            .font(.system(size: 13, weight: .regular))
            .foregroundStyle(.black.opacity(0.6))
    }
    
    private var offers: some View {
        VStack(spacing: 4) {
            ForEach(Array(products.enumerated()), id: \.offset) { offset, product in
                Button {
                    selectedIndex = offset
                    purchase(product)
                } label: {
                    labelOffer(from: product, index: offset)
                }
            }
        }
    }
    
    @ViewBuilder
    private func labelOffer(from product: PremiumProduct, index: Int) -> some View {
        let isSelected = selectedIndex == index
        
        HStack(spacing: 4) {
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)
                
                Text(consumableString(for: product))
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(isSelected ? .black.opacity(0.8) : .black.opacity(0.6))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(product.pricePerPeriod)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.black)
        }
        .padding(.horizontal)
        .frame(height: 54)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? .black : .gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
        )
    }
    
    private func consumableString(for product: PremiumProduct) -> String {
        guard let consumable = product.consumable, let unit = product.consumableUnit else {
            return product.pricePerWeek
        }
        return "\(consumable) \(unit)"
    }
    
    private var nextButton: some View {
        Button(action: {
            guard let product = selectedProduct else { return }
            purchase(product)
        }) {
            Text(buttonTitle())
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(RoundedRectangle(cornerRadius: 100).fill(.black))
        }
        .disabled(isLoading)
    }
    
    private func buttonTitle() -> String {
        if let product = selectedProduct {
            return premium.consumablePaywall.buttonTitle(for: product)
        }
        return "Purchase"
    }
    
    private func purchase(_ product: PremiumProduct) {
        Task {
            isLoading = true
            let result = await premium.purchase(product, from: .consumable)
            handleResult(result)
            isLoading = false
        }
    }
    
    @MainActor
    private func handleResult(_ result: Result<Void, PremiumError>) {
        switch result {
        case .success:
            onDismiss()
        case .failure(let error):
            alertMessage = error.localizedDescription
            if case .cancelled = error {
                isShowCancelledAlert = true
            } else {
                alertTitle = "Error"
                isShowAlert = true
            }
        }
    }
}
