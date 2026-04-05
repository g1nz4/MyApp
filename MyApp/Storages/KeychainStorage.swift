import Foundation
import KeychainAccess

final class KeychainStorage {
    static let shared = KeychainStorage()
    
    private let keychain = Keychain(service: "com.myapp.keychain-storage")
    private let passwordKey = "user_password"
    
    func isHasPassword() -> Bool {
        (try? keychain.get(passwordKey)) != nil
    }
    
    func savePassword(_ password: String) throws {
        try keychain.set(password, key: passwordKey)
    }
    
    func isValidatePassword(password: String) -> Bool {
        guard let stored = try? keychain.get(passwordKey) else { return false }
        return stored == password
    }
    
    func removePassword() throws {
        try keychain.remove(passwordKey)
    }
}
