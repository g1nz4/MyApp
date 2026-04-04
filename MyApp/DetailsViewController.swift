import UIKit

final class DetailsViewController: UIViewController {
    
    private let image: Image
    
    private lazy var fileImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    init(image: Image) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = image.userTitle
        setupUI()
        loadData()
    }
    
    private func setupUI() {
        view.addSubview(fileImageView)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            fileImageView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 25.0),
            fileImageView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            fileImageView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10.0),
            fileImageView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10.0),
            fileImageView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -10.0)
        ])
    }
    
    private func loadData() {
        if let data = try? Data(contentsOf: image.url),
           let img = UIImage(data: data) {
            fileImageView.image = img
        }
    }
}
