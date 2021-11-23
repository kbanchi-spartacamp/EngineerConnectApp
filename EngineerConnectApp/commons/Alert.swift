//
//  Alert.swift
//  EngineerConnectApp
//
//  Created by 伴地慶介 on 2021/11/23.
//

import Foundation
import UIKit

class Alert: UIAlertController {

    func showAlert(title: String, messaage: String, viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: messaage, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(alertAction)
        viewController.present(alert, animated: true)
    }

}
