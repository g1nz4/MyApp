import Foundation

final class SettingsStorage {
    
    static let shared = SettingsStorage()
    
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let sort = "sort"
    }
    
    var sort: Bool {
        get {
            if defaults.object(forKey: Keys.sort) == nil {
                return true
            }
            return defaults.bool(forKey: Keys.sort)
        }
        set {
            defaults.set(newValue, forKey: Keys.sort)
        }
    }
}
