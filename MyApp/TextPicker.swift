import Foundation
import UIKit

final class TextPicker {
    static let shared = TextPicker()
    
    enum Create {
        case folder
        case image
    }
    
    func showError(
        in viewController: UIViewController,
        with message: String
    ) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        let alertAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(alertAction)
        viewController.present(alert, animated: true)
    }
    
    func showAddFolderOrImage(
        in viewController: UIViewController,
        with create: Create,
        completion: @escaping ((_ title: String) -> Void)
    ) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        if create == .folder {
            alert.title = "You created a new folder"
            alert.addTextField { text in
                text.placeholder = "Folder name"
            }
            
        } else if create == .image {
            alert.title = "You add a new image"
            alert.addTextField { text in
                text.placeholder = "Image name"
            }
        }
        
        let actionOk = UIAlertAction(title: "OK", style: .default) { _ in
            if let title = alert.textFields?[0].text {
                completion(title)
            }
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(actionOk)
        alert.addAction(actionCancel)
        viewController.present(alert, animated: true)
    }
}
