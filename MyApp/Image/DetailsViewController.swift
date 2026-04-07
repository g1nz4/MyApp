import UIKit

final class DetailsViewController: UIViewController {
    
    private let image: Image
    
    private lazy var fileImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 18.0, weight: .semibold)
        
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16.0, weight: .medium)
        label.textAlignment = .left
        
        return label
    }()
    
    private lazy var sizeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16.0, weight: .medium)
        label.textAlignment = .right
        
        return label
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
        [fileImageView, titleLabel, dateLabel, sizeLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10.0),
            titleLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10.0),
            titleLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10.0),
            titleLabel.heightAnchor.constraint(equalToConstant: 30.0),
            
            fileImageView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10.0),
            fileImageView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10.0),
            fileImageView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10.0),
            
            dateLabel.topAnchor.constraint(equalTo: fileImageView.bottomAnchor, constant: 10.0),
            dateLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10.0),
            dateLabel.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -10.0),
            dateLabel.widthAnchor.constraint(equalToConstant: 150.0),
            dateLabel.heightAnchor.constraint(equalToConstant: 30.0),
            
            sizeLabel.topAnchor.constraint(equalTo: fileImageView.bottomAnchor, constant: 10.0),
            sizeLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10.0),
            sizeLabel.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -10.0),
            sizeLabel.widthAnchor.constraint(equalToConstant: 100.0),
            sizeLabel.heightAnchor.constraint(equalToConstant: 30.0)
        ])
    }
    
    private func loadData() {
        if let data = try? Data(contentsOf: image.url),
           let img = UIImage(data: data) {
            fileImageView.image = img
        }
    }
}
