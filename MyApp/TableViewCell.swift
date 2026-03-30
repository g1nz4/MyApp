import UIKit

final class TableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "TableViewcell"
    
    private lazy var image: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(with url: URL) {
        image.image = nil
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
           let loadedImage = UIImage(contentsOfFile: url.path)
            
            DispatchQueue.main.async {
                self?.image.image = loadedImage
            }
        }
    }
    
    private func setupUI() {
        addSubview(image)
        
        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: topAnchor, constant: 10.0),
            image.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.0),
            image.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.0),
            image.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10.0),
            image.heightAnchor.constraint(equalToConstant: 200.0)
        ])
    }
}
