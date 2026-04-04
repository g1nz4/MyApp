import UIKit

final class ImageViewController: UIViewController {

    private let viewModel: ImageViewModel
    private var selectedData: Data?
    
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
        
        return table
    }()
    
    init() {
        let directoryURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask)[0]
        let storage = ImageStorage(directory: directoryURL)
        self.viewModel = ImageViewModel(storage: storage, directory: directoryURL)
        super.init(nibName: nil, bundle: nil)
    }
    
    init(storage: ImageStorageProtocol, directory: URL, title: String) {
        self.viewModel = ImageViewModel(storage: storage, directory: directory)
        super.init(nibName: nil, bundle: nil)
        self.title = title
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
        let addImageButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addTapped)
        )
        
        let addFolderButton = UIBarButtonItem(
            image: UIImage(systemName: "folder.badge.plus"),
            style: .plain,
            target: self,
            action: #selector(addFolderTapped)
        )
        navigationItem.rightBarButtonItems = [addImageButton, addFolderButton]
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
        viewModel.onLoadData = { [weak self] _, _ in
            self?.tableView.reloadData()
        }
        
        viewModel.onInsertItem = { [weak self] index in
            guard let self = self else { return }
            
            let row = self.viewModel.folders.count + index
            let indexPath = IndexPath(row: row, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
        }
        
        viewModel.onDeleteItem = { [weak self] index in
            guard let self = self else { return }
            
            let row = self.viewModel.folders.count + index
            let indexPath = IndexPath(row: row, section: 0)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        viewModel.onError = { [weak self] message in
            guard let self = self else { return }
            
            TextPicker.shared.showError(in: self, with: message)
        }
    }
    
    private func showAlertForAddNewImage() {
        guard let data = selectedData else { return }
        
        TextPicker.shared.showAddFolderOrImage(
            in: self,
            with: .image) { [weak self] title in
                guard let self = self else {return}
                
                self.viewModel.add(imageData: data, name: title)
                self.selectedData = nil
        }
    }
    
    @objc private func addTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    @objc private func addFolderTapped() {
        TextPicker.shared.showAddFolderOrImage(
            in: self,
            with: .folder) { [weak self] title in
                self?.viewModel.addFolder(name: title)
        }
    }
}

extension ImageViewController: UITableViewDataSource {
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        viewModel.folders.count + viewModel.images.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        if indexPath.row < viewModel.folders.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "FolderCell")
            let folder = viewModel.folders[indexPath.row]
            cell.textLabel?.text = folder.name
            cell.accessoryType = .disclosureIndicator
            
            return cell
            
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: TableViewCell.reuseIdentifier,
                for: indexPath) as? TableViewCell else {
                return UITableViewCell()
            }
            let index = indexPath.row - viewModel.folders.count
            let imageData = viewModel.images[index]
            cell.configureCell(with: imageData)
            
            return cell
        }
    }
}
extension ImageViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row < viewModel.folders.count {
            let folder = viewModel.folders[indexPath.row]
            let storage = viewModel.instanceStorage
            let vc = ImageViewController(
                storage: storage,
                directory: folder.url,
                title: folder.name
            )
            navigationController?.pushViewController(vc, animated: true)
            
        } else {
            let index = indexPath.row - viewModel.folders.count
            let image = viewModel.images[index]
            let detailsVC = DetailsViewController(image: image)
            detailsVC.modalPresentationStyle = .formSheet
            navigationController?.present(detailsVC, animated: true)
        }
    }
    
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
            
            selectedData = data
            
            DispatchQueue.main.async {
                picker.dismiss(animated: true) { [weak self] in
                    self?.showAlertForAddNewImage()
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

