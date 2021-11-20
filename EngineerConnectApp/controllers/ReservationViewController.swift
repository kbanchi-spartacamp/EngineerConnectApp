//
//  ReservationViewController.swift
//  EngineerConnectApp
//
//  Created by 伴地慶介 on 2021/11/19.
//

import UIKit
import AuthenticationServices
import Alamofire
import SwiftyJSON
import KeychainAccess

class ReservationViewController: UIViewController {

    let consts = Constants.shared
    var mentors:[Mentor] = []
    
    @IBOutlet weak var scheduleTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        scheduleTableView.dataSource = self
        
        getMentorsScheduleInfo()
    }
    
    func getMentorsScheduleInfo() {
        let keychain = Keychain(service: consts.service)
        guard let accessToken = keychain["access_token"] else { return }
        guard let user_id = keychain["user_id"] else { return }
        let url = URL(string: consts.baseUrl + "/mentors?user_id=" + user_id)!
        let headers: HTTPHeaders = [
            .authorization(bearerToken: accessToken)
        ]
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
                // success
            case .success(let value):
                self.mentors = []
                let json = JSON(value).arrayValue
                print(json)
                for mentors in json {
                    let mentor = Mentor(
                        id: mentors["id"].int!,
                        name: mentors["name"].string!,
                        email: mentors["email"].string!,
                        profile: mentors["profile"].string ?? ""
                    )
                    self.mentors.append(mentor)
                }
                self.scheduleTableView.reloadData()
                // fail
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
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

extension ReservationViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mentors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = mentors[indexPath.row].name
        return cell
    }
    
    
}
