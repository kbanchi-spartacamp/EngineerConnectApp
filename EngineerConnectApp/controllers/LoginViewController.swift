//
//  LoginViewController.swift
//  EngineerConnectApp
//
//  Created by 伴地慶介 on 2021/11/19.
//

import UIKit
import AuthenticationServices
import Alamofire
import SwiftyJSON
import KeychainAccess

class LoginViewController: UIViewController {
    
    let consts = Constants.shared
    var token = ""
    var session: ASWebAuthenticationSession?
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // clear keychain
//        let keychain = Keychain(service: consts.service)
//        keychain["access_token"] = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if isLogin() {
            let keychain = Keychain(service: consts.service)
            token = keychain["access_token"]!
            transitionToTabBar()
        }

    }
    
    func getAccessToken() {
        let url = URL(string: consts.baseUrl + "/user/login")!
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "ACCEPT": "application/json"
        ]
        let parameters: Parameters = [
            "email": emailTextField.text!,
            "password": passwordTextField.text!
        ]
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
//                print(json)
                let token: String? = json["token"].string
                guard let accessToken = token else { return }
                self.token = accessToken
                //このアプリ用のキーチェーンを生成
                let keychain = Keychain(service: self.consts.service)
                //キーを設定して保存
                keychain["access_token"] = accessToken
                self.getUserInfo(accessToken: accessToken)
            case .failure(let err):
                print("### ERROR ###")
                print(err.localizedDescription)
            }
        }
    }
    
    func getUserInfo(accessToken: String) {
        let keychain = Keychain(service: consts.service)
        let url = URL(string: consts.baseUrl + "/user")!
        let headers: HTTPHeaders = [
            .authorization(bearerToken: accessToken)
        ]
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                let user = User(
                    id: json["id"].int!,
                    name: json["name"].string!,
                    email: json["email"].string!,
                    profile_photo_url: json["profile_photo_url"].string!
                )
                //キーを設定して保存
                keychain["user_id"] = String(user.id)
            case .failure(let err):
                print("### ERROR ###")
                print(err.localizedDescription)
            }
        }
    }
    
    func isLogin() -> Bool {
        let keychain = Keychain(service: consts.service)
        if keychain["access_token"] != nil {
            return true
        } else {
            return false
        }
    }
    
    @IBAction func tapLoginButton(_ sender: Any) {
        getAccessToken()
        transitionToTabBar()
        
        // 認証セッションと通常のブラウザで閲覧情報やCookieを共有しないように設定
        session?.prefersEphemeralWebBrowserSession = true
        // セッションの開始(これがないと認証できない)
        session?.start()
    }
    
    func transitionToTabBar() {
       let tabBarContorller = self.storyboard?.instantiateViewController(withIdentifier: "TabBar") as! UITabBarController
       tabBarContorller.modalPresentationStyle = .fullScreen
       present(tabBarContorller, animated: true, completion: nil)
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
