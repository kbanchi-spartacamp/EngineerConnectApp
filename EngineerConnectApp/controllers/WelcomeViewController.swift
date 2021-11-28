//
//  WelcomeViewController.swift
//  EngineerConnectApp
//
//  Created by 伴地慶介 on 2021/11/25.
//

import UIKit
import PKHUD

class WelcomeViewController: UIViewController {

    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        startButton.layer.cornerRadius = 10.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func tapStartButton(_ sender: Any) {
        HUD.flash(.progress, delay: 3) {
             _ in
            self.transitionNextViewController()
        }
    }
    
    func transitionNextViewController() {
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "loginViewController") as! LoginViewController
        nextVC.modalPresentationStyle = .fullScreen
        present(nextVC, animated: true, completion: nil)
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
