import Foundation
import KeychainAccess

protocol KeychainStorageProtocol {
    func isHasPassword() -> Bool
    func savePassword(_ password: String) throws
    func isValidatePassword(password: String) -> Bool
    func removePassword() throws
}

final class KeychainStorage: KeychainStorageProtocol {
    
    private let keychain: Keychain
    private let passwordKey = "user_password"
    
    init(service: String = "com.myapp.keychain-storage") {
        self.keychain = Keychain(service: service)
    }
    
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
