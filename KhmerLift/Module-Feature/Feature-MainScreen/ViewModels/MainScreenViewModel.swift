import SwiftUI
import Observation

@MainActor
@Observable
final class MainScreenViewModel {
    var selectedTab: TabItem = .home {
        didSet {
            dismissKeyboard()
        }
    }
    
    var showAddScreen: Bool = false
    
    func handleAddTapped() {
        dismissKeyboard()
        showAddScreen = true
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
