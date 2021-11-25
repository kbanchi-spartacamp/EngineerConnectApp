//
//  RegisterViewController.swift
//  EngineerConnectApp
//
//  Created by 伴地慶介 on 2021/11/25.
//

import UIKit
import AuthenticationServices
import Alamofire
import SwiftyJSON
import KeychainAccess

class RegisterViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordVerifyTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    let consts = Constants.shared
    var token = ""
    var session: ASWebAuthenticationSession?
    let alert = Alert()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        registerButton.layer.cornerRadius = 10.0
        
    }
    
    @IBAction func tapRegisterButton(_ sender: Any) {
        if passwordTextField.text == passwordVerifyTextField.text {
            register()
            self.alert.showAlert(title: "Create Account", messaage: "complete create account.", viewController: self)
            self.clearTextField()
        } else {
            self.alert.showAlert(title: "ERROR", messaage: "password verify error.", viewController: self)
        }
    }
    
    func register() {
        let url = URL(string: consts.baseUrl + "/user/register")!
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "ACCEPT": "application/json"
        ]
        let parameters: Parameters = [
            "name": nameTextField.text!,
            "email": emailTextField.text!,
            "password": passwordTextField.text!
        ]
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
            case .failure(let err):
                print("### ERROR ###")
                print(err.localizedDescription)
            }
        }
    }
    
    func clearTextField() {
        nameTextField.text = ""
        emailTextField.text = ""
        passwordTextField.text = ""
        passwordVerifyTextField.text = ""
    }
    
    @IBAction func tapBackButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
