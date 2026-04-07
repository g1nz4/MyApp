import Foundation

protocol LoginViewModelProtocol: AnyObject {
    var modeDidChange: ((LoginMode) -> Void)? { get set }
    var showError: ((String) -> Void)? { get set }
    var authSuccess: (() -> Void)? { get set }
    var mode: LoginMode { get }
    
    func updateMode(_ newMode: LoginMode)
    func buttonTap(text: String?)
}

enum LoginMode {
    case create(firstStep: Bool)
    case login
}

final class LoginViewModel: LoginViewModelProtocol {
    
    var modeDidChange: ((LoginMode) -> Void)?
    var showError: ((String) -> Void)?
    var authSuccess: (() -> Void)?
    
    private(set) var mode: LoginMode
    private var firstInput: String?
    
    private let storage: KeychainStorageProtocol
    
    init(storage: KeychainStorageProtocol) {
        self.storage = storage
        
        if storage.isHasPassword() {
            mode = .login
        } else {
            mode = .create(firstStep: true)
        }
    }
    
    func updateMode(_ newMode: LoginMode) {
        mode = newMode
        modeDidChange?(newMode)
    }
    
    func buttonTap(text: String?) {
        guard let text = text, !text.isEmpty else {
            showError?("Введите пароль")
            return
        }
        
        switch mode {
        case .create(let firstStep):
            createPassword(text: text, firstStep: firstStep)
        case .login:
            check(text: text)
        }
    }
    
    private func createPassword(text: String, firstStep: Bool) {
        guard text.count >= 4 else {
            showError?("Пароль должен содержать минимум 4 символа")
            return
        }
        
        if firstStep {
            firstInput = text
            updateMode(.create(firstStep: false))
        } else {
            guard let first = firstInput else {
                recreatePassword(with: "Ошибка. Попробуйте ещё раз.")
                return
            }
            guard first == text else {
                recreatePassword(with: "Пароли не совпадают. Попробуйте ещё раз.")
                return
            }
            
            do {
                try storage.savePassword(text)
                authSuccess?()
            } catch {
                recreatePassword(with: "Не удалось сохранить пароль.")
            }
        }
    }
    
    private func recreatePassword(with message: String) {
        firstInput = nil
        updateMode(.create(firstStep: true))
        showError?(message)
    }
    
    private func check(text: String) {
        guard storage.isValidatePassword(password: text) else {
            showError?("Неверный пароль")
            return
        }
        authSuccess?()
    }
}
