import UIKit

final class SettingsViewController: UITableViewController {
    
    private let viewModel: SettingsViewModel
    
    init(viewModel: SettingsViewModel = SettingsViewModel()) {
        self.viewModel = viewModel
        super.init(style: .insetGrouped)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private enum Row: Int, CaseIterable {
        case sort
        case changePassword
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        bindingViewModel()
    }
    
    private func bindingViewModel() {
        viewModel.changePassword = { [weak self] in
            self?.presentChangePassword()
        }
    }
    
    private func presentChangePassword() {
        let viewModel = LoginViewModel()
        viewModel.updateMode(.create(firstStep: true))
        let vc = LoginViewController(viewModel: viewModel)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }
    
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        Row.allCases.count
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let row = Row(rawValue: indexPath.row)!
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        switch row {
        case .sort:
            cell.textLabel?.text = "Sort by: A -> Z"
           
            let uiSwitch = UISwitch()
            uiSwitch.isOn = viewModel.sort
            uiSwitch.addTarget(self, action: #selector(sortSwitchChanged(_:)), for: .valueChanged)
            cell.accessoryView = uiSwitch
            cell.selectionStyle = .none
            
        case .changePassword:
            cell.textLabel?.text = "Change password"
            cell.accessoryType = .disclosureIndicator
            cell.accessoryView = nil
            cell.selectionStyle = .default
        }
        
        return cell
    }
    
    @objc private func sortSwitchChanged(_ sender: UISwitch) {
        viewModel.sort = sender.isOn
    }
    
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let row = Row(rawValue: indexPath.row) else { return }
        
        switch row {
        case .sort:
            break
        case .changePassword:
            viewModel.didTapChangePassword()
        }
    }
}
