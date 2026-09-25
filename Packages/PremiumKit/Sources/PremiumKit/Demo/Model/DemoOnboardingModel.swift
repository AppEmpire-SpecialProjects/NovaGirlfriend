enum Onboarding: Int, CaseIterable {
    case page1, page2, page3, paywall
    
    var id: Int {
        rawValue
    }
    
    var next: Onboarding? {
        switch self {
        case .page1: .page2
        case .page2: .page3
        case .page3: .paywall
        case .paywall: nil
        }
    }
    
    func inputModel() -> OnboardingInputModel {
        OnboardingInputModel(from: self)
    }
}

struct OnboardingInputModel {
    let title: String
    let subtitle: String
    let message: String
    var buttonTitle: String
}

extension OnboardingInputModel {
    
    init(from page: Onboarding) {
        buttonTitle = "Continue"
        
        switch page {
        case .page1:
            title = "Title 1"
            subtitle = "Subtitle 1"
            message = "Message 1"
            
        case .page2:
            title = "Title 2"
            subtitle = "Subtitle 2"
            message = "Message 2"
            
        case .page3:
            title = "Title 3"
            subtitle = "Subtitle 3"
            message = "Message 3"
            
        case .paywall:
            title = ""
            subtitle = ""
            message = ""
            
        }
    }
}
