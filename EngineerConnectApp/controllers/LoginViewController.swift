//
//  LoginViewController.swift
//  EngineerConnectApp
//
//  Created by 伴地慶介 on 2021/11/19.
//

import UIKit

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func tapLoginButton(_ sender: Any) {
        self.transitionToTabBar()
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
