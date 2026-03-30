import UIKit

final class ImageViewController: UIViewController {

    private let viewModel: ImageViewModel
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.register(
            TableViewCell.self,
            forCellReuseIdentifier: TableViewCell.reuseIdentifier
        )
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        table.estimatedRowHeight = 200.0
        
        return table
    }()
    
    init() {
        let directoryURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask)[0]
        let storage = ImageStorage(directory: directoryURL)
        self.viewModel = ImageViewModel(storage: storage)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Images"
        setupNavigationBar()
        setupUI()
        bindingViewModel()
        viewModel.load()
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Add",
            style: .plain,
            target: self,
            action: #selector(addTapped)
        )
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
    
    private func bindingViewModel() {
        viewModel.onLoadData = { [weak self] _ in
            self?.tableView.reloadData()
        }
        
        viewModel.onInsertItem = { [weak self] index in
            guard let self = self else { return }
            
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .bottom)
        }
        
        viewModel.onDeleteItem = { [weak self] index in
            guard let self = self else { return }
            
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        viewModel.onError = { [weak self] message in
            self?.showAlert(message: message)
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: "Oops",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func addTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
}

extension ImageViewController: UITableViewDataSource {
   
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        viewModel.images.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TableViewCell.reuseIdentifier,
            for: indexPath) as? TableViewCell else {
            return UITableViewCell()
        }
        
        let imageData = viewModel.images[indexPath.row]
        cell.configureCell(with: imageData.url)
        
        return cell
    }
}

extension ImageViewController: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(
            style: .destructive,
            title: "Delete"
        ) {  [weak self] _, _, completion in
            self?.viewModel.delete(at: indexPath.row)
            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
}

extension ImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        guard let image = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage) else {
            picker.dismiss(animated: true)
            
            return
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self,
                  let data = image.jpegData(compressionQuality: 1.0) else {
                DispatchQueue.main.async {
                    picker.dismiss(animated: true)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                self.viewModel.add(imageData: data)
                picker.dismiss(animated: true)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

