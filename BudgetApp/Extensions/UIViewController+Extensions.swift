import Foundation
import UIKit

extension UIViewController {
    func showAlert(title: String, message: String, buttonTitle: String = "OK", action: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: buttonTitle, style: .default) { _ in
            action?()
        }
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}
