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
import MultiSlider
import PKHUD

class ReservationViewController: UIViewController {

    let consts = Constants.shared
    var mentors:[Mentor] = []
    var selected_skill: String = ""
    var skillCategories:[SkillCategory] = []
    var day = ""
    var start_time = ""
    var alert = Alert()
    
    let slider = MultiSlider()
    
    let data = ["A","B","C","D","E"]
    
    @IBOutlet weak var scheduleTableView: UITableView!
    @IBOutlet weak var dateSegmentedControl: UISegmentedControl!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var categoryPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        scheduleTableView.dataSource = self
        scheduleTableView.delegate = self
        
        categoryPickerView.dataSource = self
        categoryPickerView.delegate = self
                
        getSkillCategoryInfo()
        
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "Y-MM-dd(E)", options: 0, locale: Locale(identifier: "ja_JP"))
        let today = formatter.string(from: Date())
        let day = today.prefix(10)
        let startIndex = today.index(today.startIndex, offsetBy: 11)
        let endIndex = today.index(today.endIndex,offsetBy: -2)
        let day_of_week = String(today[startIndex...endIndex])
        getMentorsScheduleInfo(skill_category_id:"", start_time:"", end_time:"", day:String(day), day_of_week: day_of_week, bookmark:"")
        
        setMultiSlider()
        
        setDateSegmentedControl()
        
        searchButton.layer.cornerRadius = 10.0
        
    }
    
    func setMultiSlider() {
        slider.minimumValue = 0.0
        slider.maximumValue = 24.0
        slider.value = [0.0, 24.0]
        slider.addTarget(self, action: #selector(sliderChanged(slider:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderDragEnded(slider:)), for: .valueChanged)
        slider.outerTrackColor = .lightGray
        slider.orientation = .horizontal
        slider.valueLabelPosition = .bottom
        slider.valueLabelFormatter.positiveSuffix = "時"
        slider.snapStepSize = 1
        
        slider.frame = CGRect(x:((self.view.bounds.width-320)/2),y:170,width:320,height:50)

        view.addSubview(slider)
    }
    
    @objc func sliderChanged(slider: MultiSlider) {
        print("thumb \(slider.draggedThumbIndex) moved")
        print("now thumbs are at \(slider.value)")
    }
    
    @objc func sliderDragEnded(slider: MultiSlider) {
        print("thumb \(slider.draggedThumbIndex) touch up inside")
        print("now thumbs are at \(slider.value)")
    }
    
    func setDateSegmentedControl() {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MM/dd(E)", options: 0, locale: Locale(identifier: "ja_JP"))
        var date = Date()
        for i in 0..<7 {
            dateSegmentedControl.setTitle(formatter.string(from: date), forSegmentAt: i)
            date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
        }
    }
    
    @IBAction func selectSegmentedControl(_ sender: Any) {
    }
    
    func getMentorsScheduleInfo(skill_category_id:String, start_time:String, end_time:String, day:String, day_of_week: String, bookmark:String) {
        HUD.show(.progress)
        let keychain = Keychain(service: consts.service)
        guard let user_id = keychain["user_id"] else { return print("no user_id")}
        guard let accessToken = keychain["access_token"] else { return print("no token")}
        let url = URL(string: consts.baseUrl + "/mentor_schedules?user_id=" + user_id + "&skill_category_id=" + skill_category_id + "&start_time=" + start_time + "&end_time=" + end_time + "&day=" + day + "&day_of_week=" + day_of_week + "&bookmark=" + bookmark)!
        let headers: HTTPHeaders = [
            .authorization(bearerToken: accessToken)
        ]
        print(url)
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
                // success
            case .success(let value):
                self.mentors = []
                print(value)
                let json = JSON(value).arrayValue
                for mentors in json {
                    let mentor = Mentor(
                        id: mentors["id"].int!,
                        name: mentors["name"].string!,
                        email: mentors["email"].string!,
                        profile: mentors["profile"].string ?? "",
                        profile_photo_url: mentors["profile_photo_url"].string ?? ""
                    )
                    self.mentors.append(mentor)
                }
                self.day = day
                self.start_time = start_time
                self.scheduleTableView.reloadData()
                if json.isEmpty {
                    self.alert.showAlert(title: "No Mentor", messaage: "target mentors are not found", viewController: self)
                }
                HUD.hide()
                // fail
            case .failure(let err):
                HUD.hide()
                print(err.localizedDescription)
            }
        }
    }
    
    func getSkillCategoryInfo() {
        let keychain = Keychain(service: consts.service)
        guard let accessToken = keychain["access_token"] else { return }
        let url = URL(string: consts.baseUrl + "/skill_categories")!
        let headers: HTTPHeaders = [
            .authorization(bearerToken: accessToken)
        ]
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
                // success
            case .success(let value):
                self.skillCategories = []
                let json = JSON(value).arrayValue
                print(json)
                for skillCategories in json {
                    let skillCategory = SkillCategory(
                        id: skillCategories["id"].int!,
                        name: skillCategories["name"].string!
                    )
                    self.skillCategories.append(skillCategory)
                }
                self.categoryPickerView.reloadAllComponents()
                // fail
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }

    @IBAction func tapSearchButton(_ sender: Any) {
        let selectedDay = dateSegmentedControl.titleForSegment(at: dateSegmentedControl.selectedSegmentIndex)!
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "Y-MM-dd", options: 0, locale: Locale(identifier: "ja_JP"))
        let day = formatter.string(from: Date()).prefix(4) + "-" + String(selectedDay.replacingOccurrences(of: "/", with: "-").prefix(5))
        let startIndex = selectedDay.index(selectedDay.startIndex, offsetBy: 6)
        let endIndex = selectedDay.index(selectedDay.endIndex,offsetBy: -2)
        let day_of_week = String(selectedDay[startIndex...endIndex])
        let start_time = String(Double(slider.value[0])).replacingOccurrences(of: ".", with: ":")
        let end_time = String(Double(slider.value[1])).replacingOccurrences(of: ".", with: ":")
        getMentorsScheduleInfo(skill_category_id:self.selected_skill, start_time:start_time, end_time:end_time, day:String(day), day_of_week: day_of_week, bookmark:"")
        
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

extension ReservationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "reservationDetailViewController") as! ReservationDetailViewController
        nextVC.mentor_id = mentors[indexPath.row].id
        nextVC.day = self.day
        nextVC.start_time = self.start_time
        nextVC.modalPresentationStyle = .fullScreen
        present(nextVC, animated: true, completion: nil)
    }
}

extension ReservationViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return skillCategories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return skillCategories[row].name
    }
    
}

extension ReservationViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selected_skill = String(skillCategories[row].id)
        print(selected_skill)
    }
}
