//
//  ReservationDetailViewController.swift
//  EngineerConnectApp
//
//  Created by 伴地慶介 on 2021/11/23.
//

import UIKit
import AuthenticationServices
import Alamofire
import SwiftyJSON
import KeychainAccess

class ReservationDetailViewController: UIViewController {

    let consts = Constants.shared
    var mentor_id = 0
    var day = ""
    var start_time = ""
    var mentor: Mentor!
    let alert = Alert()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        getMentorInfo()
    }
    
    func getMentorInfo() {
        let keychain = Keychain(service: consts.service)
        guard let accessToken = keychain["access_token"] else { return }
        let url = URL(string: consts.baseUrl + "/mentors/" + String(mentor_id))!
        let headers: HTTPHeaders = [
            .authorization(bearerToken: accessToken)
        ]
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                let mentor = Mentor(
                    id: json["id"].int!,
                    name: json["name"].string!,
                    email: json["email"].string!,
                    profile: json["profile"].string!,
                    profile_photo_url: json["profile_photo_url"].string!
                )
                self.mentor = mentor
                self.setMentorInfo(mentor: mentor)
            case .failure(let err):
                print("### ERROR ###")
                print(err.localizedDescription)
            }
        }
    }
    
    func setMentorInfo(mentor:Mentor) {
        nameLabel.text = mentor.name
        profileLabel.text = mentor.profile
    }
    
    @IBAction func tapReserveButton(_ sender: Any) {
        let keychain = Keychain(service: consts.service)
        guard let accessToken = keychain["access_token"] else { return }
        guard let user_id = keychain["user_id"] else { return }
        let url = URL(string: consts.baseUrl + "/reservations")!
        let parameters: Parameters = [
            "user_id": user_id,
            "mentor_id": mentor_id,
            "day": day,
            "start_time": "20:00"
        ]
        let headers :HTTPHeaders = [
            .authorization(bearerToken: accessToken)
        ]
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print("JSON: \n\(json)")
                self.alert.showAlert(title: "Reservation", messaage: "new reservation", viewController: self)
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
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
