import UIKit

final class LoginViewController: UIViewController {
    
    private let viewModel: LoginViewModel
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter password"
        textField.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        return textField
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.titleLabel?.font = .systemFont(ofSize: 18.0, weight: .semibold)
        button.layer.cornerRadius = 10.0
        button.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [passwordTextField, actionButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16.0
        stack.alignment = .center
        
        return stack
    }()
    
    init(viewModel: LoginViewModel = LoginViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "MyApp"
        setupUI()
        bindingViewModel()
        viewModel.modeDidChange?(viewModel.mode)
    }
    
    private func setupUI() {
        view.addSubview(stackView)
       
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor, constant: -50.0),
            stackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16.0),
            stackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16.0),
            
            passwordTextField.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            
            actionButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            actionButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
        ])
    }
   
    private func bindingViewModel() {
        viewModel.modeDidChange = { [weak self] mode in
            guard let self = self else { return }
           
            self.passwordTextField.text = ""
            
            switch mode {
            case .create(let firstStep):
                self.title = "Create password"
                if firstStep {
                    self.actionButton.setTitle("Create password", for: .normal)
                    self.passwordTextField.placeholder = "Enter password"
                } else {
                    self.actionButton.setTitle("Repeat password", for: .normal)
                    self.passwordTextField.placeholder = "Repeat password"
                }
            case .login:
                self.actionButton.setTitle("Enter password", for: .normal)
                self.passwordTextField.placeholder = "Password"
            }
        }
        
        viewModel.showError = { message in
            TextPicker.shared.showError(in: self, with: message)
        }
        
        viewModel.authSuccess = { [weak self] in
            self?.openMainTabBar()
        }
    }
    
    private func openMainTabBar() {
        let tabBar = MainTabBarController()
        tabBar.modalPresentationStyle = .fullScreen
        present(tabBar, animated: true)
    }
    
    @objc private func buttonTapped() {
        viewModel.buttonTap(text: passwordTextField.text)
    }
}
