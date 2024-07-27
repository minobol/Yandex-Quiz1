import UIKit

final class AlertPresenter: AlertPresenterDelegate {
    
    weak var alertView: AlertPresenterProtocol?
    
    func alertShow(alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) {_ in alertModel.completion()}
        
        alert.addAction(action)
        alertView?.present(alert, animated: true, completion: nil)
    }
}


