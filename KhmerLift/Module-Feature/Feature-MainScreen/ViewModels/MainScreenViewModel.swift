import SwiftUI
import Observation

@MainActor
@Observable
final class MainScreenViewModel {
    private let backgroundKey = "selectedBackgroundFileName"
    
    var selectedTab: TabItem = .home {
        didSet {
            dismissKeyboard()
        }
    }
    
    var showAddScreen: Bool = false
    var selectedBackgroundFileName: String = "bike-video"
    
    init() {
        self.selectedBackgroundFileName = UserDefaults.standard.string(forKey: backgroundKey) ?? "bike-video"
        
        NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.reloadBackgroundPreference()
            }
        }
    }
    
    private func reloadBackgroundPreference() {
        let updatedBackground = UserDefaults.standard.string(forKey: backgroundKey) ?? "bike-video"
        if selectedBackgroundFileName != updatedBackground {
            selectedBackgroundFileName = updatedBackground
        }
    }
    
    func handleAddTapped() {
        dismissKeyboard()
        showAddScreen = true
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
