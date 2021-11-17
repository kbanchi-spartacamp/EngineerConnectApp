//
//  SampleViewController.swift
//  EngineerConnectApp
//
//  Created by 伴地慶介 on 2021/11/17.
//

import UIKit
import AuthenticationServices
import Alamofire
import SwiftyJSON
import KeychainAccess

class SampleViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var mentors:[Mentor] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        getMentorsInfo()
    }
    
    func getMentorsInfo() {
        let url = "http://localhost/api/mentors"
        let headers: HTTPHeaders = []
        // Alamofireでリクエスト
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
                // success
            case .success(let value):
                self.mentors = []
                let json = JSON(value).arrayValue
//                print(json)
                for mentors in json {
                    let mentor = Mentor(
                        id: mentors["id"].int!,
                        name: mentors["name"].string!,
                        email: mentors["email"].string!,
                        profile: mentors["profile"].string ?? ""
                    )
                    self.mentors.append(mentor)
                }
                // print(self.myArticles)
                self.tableView.reloadData()
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

extension SampleViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mentors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = mentors[indexPath.row].name
        return cell
    }
    
}
