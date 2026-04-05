import Foundation

final class SettingsViewModel {
    
    private let storage = SettingsStorage.shared
    
    var sort: Bool {
        get { storage.sort }
        set {
            storage.sort = newValue
            NotificationCenter.default.post(name: .sortChanged, object: nil)
        }
    }
    
    var changePassword: (() -> Void)?
    
    func didTapChangePassword() {
        changePassword?()
    }
}
