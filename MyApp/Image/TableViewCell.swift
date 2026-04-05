import UIKit

final class TableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "TableViewcell"
    
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
    
    private lazy var fileImageView: UIImageView = {
        let view = UIImageView()
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
    
    func configureCell(with image: Image) {
        fileImageView.image = nil
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let loadedImage = UIImage(contentsOfFile: image.url.path)
            
            DispatchQueue.main.async {
                self?.fileImageView.image = loadedImage
            }
        }
        
        titleLabel.text = image.userTitle
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        dateLabel.text = formatter.string(from: image.date)
        
        let sizeMb = image.size / (1024 * 1024)
        sizeLabel.text = String(format: "%.2f Mb", sizeMb)
    }
    
    private func setupUI() {
        [fileImageView, titleLabel, dateLabel, sizeLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10.0),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.0),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.0),
            titleLabel.heightAnchor.constraint(equalToConstant: 30.0),
            
            fileImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            fileImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            fileImageView.widthAnchor.constraint(equalToConstant: 100.0),
            fileImageView.heightAnchor.constraint(equalToConstant: 100.0),
            
            dateLabel.topAnchor.constraint(equalTo: fileImageView.bottomAnchor, constant: 10.0),
            dateLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.0),
            dateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10.0),
            dateLabel.widthAnchor.constraint(equalToConstant: 150.0),
            dateLabel.heightAnchor.constraint(equalToConstant: 30.0),
            
            sizeLabel.topAnchor.constraint(equalTo: fileImageView.bottomAnchor, constant: 10.0),
            sizeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.0),
            sizeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10.0),
            sizeLabel.widthAnchor.constraint(equalToConstant: 100.0),
            sizeLabel.heightAnchor.constraint(equalToConstant: 30.0)
        ])
    }
}
