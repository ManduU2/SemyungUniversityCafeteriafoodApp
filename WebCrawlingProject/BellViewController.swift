//
//  BellViewController.swift
//  WebCrawlingProject
//
//  Created by 김진혁 on 3/8/24.
//

import UIKit
import FirebaseCore
import FirebaseFirestore

class BellViewController: UIViewController  {
    
    
    // 파이어스토어
    let db = Firestore.firestore()
    
    // UserDefaults key
    let switchStateKey = "SwitchState"
    
    
    var tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    
    // 토글 스위치 모양 만들기 (위치 설정 포함)
    lazy var controlSwitch: UISwitch = {
        
        
        let swicth: UISwitch = UISwitch()
        
        // 위치 설정
//            swicth.layer.position = CGPoint(x: self.view.frame.width/2, y: self.label.layer.position.y + self.label.frame.height + 10)
        
        
        // Display the border of Swicth.
        swicth.tintColor = UIColor.gray
        
        
        
        
        swicth.addTarget(self, action: #selector(onClickSwitch(sender:)), for: UIControl.Event.valueChanged)
        
        // Set initial state from UserDefaults
        if let isOn = UserDefaults.standard.value(forKey: switchStateKey) as? Bool {
            swicth.isOn = isOn
        }
        
        return swicth
    }()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        
        requestNotificationAuthorization()
        
        //self.view.addSubview(self.label)
        self.view.addSubview(self.controlSwitch)
        
        
        
        navigationItem.title = "알림 설정"
        
        // Check notification settings
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                // Update switch based on notification authorization status
                let isOn = settings.authorizationStatus == .authorized
                self.updateButtonState(isOn: isOn)
                self.saveSwitchState(isOn: isOn)
            }
        }
        
        applyConstraints()
        
        
    }
    
    fileprivate func applyConstraints() {
        self.view.addSubview(self.tableView)
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        
    }
    
    
    
    // Save switch state to UserDefaults
    func saveSwitchState(isOn: Bool) {
        UserDefaults.standard.set(isOn, forKey: switchStateKey)
    }
    
    func requestNotificationAuthorization() {
           UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
               if granted {
                   DispatchQueue.main.async {
                       self.controlSwitch.isOn = true
                       self.saveSwitchState(isOn: true)
                       self.scheduleNotification()
                   }
               } else {
                   DispatchQueue.main.async {
                       self.controlSwitch.isOn = false
                       self.saveSwitchState(isOn: false)
                   }
               }
           }
       }
    
    
    
    // 초기 버튼 상태
    func updateButtonState(isOn: Bool) {
        var text: String!
        var color: UIColor!
        
        if isOn {
            text = "On"
            color = UIColor.systemGreen
            scheduleNotification()
        } else {
            text = "Off"
            color = UIColor.gray
        }
    }
    
    
    // 아침메뉴 가져오기
    func getBreakfastMenu(completion: @escaping (String?, Error?) -> Void) {
        // 현재 날짜 데이터 포맷
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let current_date_string = formatter.string(from: Date())
        
        let docRef = db.collection("Menu").document(current_date_string)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let breakfastMenu = document.data()?["아침메뉴"] as? String {
                    let breakfastMenu = breakfastMenu.replacingOccurrences(of: "\\n", with: "\n")
                    
                    completion(breakfastMenu, nil)
                    
                } else {
                    completion(nil, nil)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    // 점심메뉴 가져오기
    func getLunchMenu(completion: @escaping (String?, Error?) -> Void) {
        // 현재 날짜 데이터 포맷
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let current_date_string = formatter.string(from: Date())
        
        let docRef = db.collection("Menu").document(current_date_string)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let lunchMenu = document.data()?["점심메뉴"] as? String {
                    let lunchMenu = lunchMenu.replacingOccurrences(of: "\\n", with: "\n")
                    completion(lunchMenu, nil)
                } else {
                    completion(nil, nil)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    // 저녁메뉴 가져오기
    func getDinnerMenu(completion: @escaping (String?, Error?) -> Void) {
        // 현재 날짜 데이터 포맷
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let current_date_string = formatter.string(from: Date())
        
        let docRef = db.collection("Menu").document(current_date_string)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let dinnerMenu = document.data()?["저녁메뉴"] as? String {
                    let dinnerMenu = dinnerMenu.replacingOccurrences(of: "\\n", with: "\n")
                    completion(dinnerMenu, nil)
                } else {
                    completion(nil, nil)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    // 알림 (Notification)
    func scheduleNotification() {
        
        // 아침메뉴 가져오기
        getBreakfastMenu { (breakfastMenu, error) in
            guard let breakfastMenu = breakfastMenu else {
                print("Error getting breakfast menu: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // 점심메뉴 가져오기
            self.getLunchMenu { (lunchMenu, error) in
                guard let lunchMenu = lunchMenu else {
                    print("Error getting lunch menu: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                // 저녁메뉴 가져오기
                self.getDinnerMenu { (dinnerMenu, error) in
                    guard let dinnerMenu = dinnerMenu else {
                        print("Error getting dinner menu: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    
                    
                    // 현재 날짜 데이터 포맷
                    let formatter = DateFormatter()
                    formatter.dateFormat = "YYYY-MM-dd"
                    let current_date_string = formatter.string(from: Date())
                    
                    
                    let content = UNMutableNotificationContent()
                    content.title = "세명대학교 조식"
                    content.body = breakfastMenu
                    content.sound = UNNotificationSound.default
                    
                    
                    
                    let content2 = UNMutableNotificationContent()
                    content2.title = "세명대학교 중식"
                    content2.body = lunchMenu
                    content2.sound = UNNotificationSound.default
                    
                    
                    
                    let content3 = UNMutableNotificationContent()
                    content3.title = "세명대학교 석식"
                    content3.body = dinnerMenu
                    content3.sound = UNNotificationSound.default
                    
                    
                    
                    // 첫 번째 알림: 08:30
                    var dateComponents1 = DateComponents()
                    dateComponents1.hour = 8
                    dateComponents1.minute = 30
                    let trigger1 = UNCalendarNotificationTrigger(dateMatching: dateComponents1, repeats: false)
                    let request1 = UNNotificationRequest(identifier: "uniqueIdentifier1", content: content, trigger: trigger1)
                    
                    
                    
                    // 두 번째 알림: 11:30
                    var dateComponents2 = DateComponents()
                    dateComponents2.hour = 11
                    dateComponents2.minute = 30
                    let trigger2 = UNCalendarNotificationTrigger(dateMatching: dateComponents2, repeats: false)
                    let request2 = UNNotificationRequest(identifier: "uniqueIdentifier2", content: content2, trigger: trigger2)
                    
                    
                    
                    // 세 번째 알림: 17:30
                    var dateComponents3 = DateComponents()
                    dateComponents3.hour = 17
                    dateComponents3.minute = 30
                    let trigger3 = UNCalendarNotificationTrigger(dateMatching: dateComponents3, repeats: false)
                    let request3 = UNNotificationRequest(identifier: "uniqueIdentifier3", content: content3, trigger: trigger3)
                    
                    
                    
                    
                    let notificationCenter = UNUserNotificationCenter.current()
                    notificationCenter.add(request1) { (error) in
                        if let error = error {
                            print("Error adding notification request1: \(error)")
                        }
                    }
                    notificationCenter.add(request2) { (error) in
                        if let error = error {
                            print("Error adding notification request2: \(error)")
                        }
                    }
                    notificationCenter.add(request3) { (error) in
                        if let error = error {
                            print("Error adding notification request3: \(error)")
                        }
                    }
                }
            }
        }
    }
    
    
    
    @objc func onClickSwitch(sender: UISwitch) {
        let isOn = sender.isOn
            updateButtonState(isOn: isOn)
            saveSwitchState(isOn: isOn)
    }
 
    
    

    
    
}


// 테이블 델리게이트
extension BellViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            // 첫 번째 섹션에는 하나의 셀만 있음
            return 1
        } else if section == 1 {
            // 두 번째 섹션에는 3개의 셀이 있음
            return 2
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        if indexPath.section == 0 && indexPath.row == 0 {
            let switchCell = UITableViewCell(style: .default, reuseIdentifier: nil)
            switchCell.selectionStyle = .none
            
            
     
            
            
            // Label
             let label = UILabel()
             label.text = "알림"
             switchCell.contentView.addSubview(label)
             label.translatesAutoresizingMaskIntoConstraints = false
             NSLayoutConstraint.activate([
                 label.leadingAnchor.constraint(equalTo: switchCell.contentView.leadingAnchor, constant: 20),
                 label.centerYAnchor.constraint(equalTo: switchCell.contentView.centerYAnchor)
             ])
            
       
            
            // Add switch to the cell's contentView
            switchCell.contentView.addSubview(controlSwitch)
            
            // Apply constraints for the switch
            controlSwitch.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                controlSwitch.centerYAnchor.constraint(equalTo: switchCell.contentView.centerYAnchor),
                controlSwitch.trailingAnchor.constraint(equalTo: switchCell.contentView.trailingAnchor, constant: -20) // Adjust the constant as per your need
            ])
            
            
            
           
            
            return switchCell
        } else if indexPath.section == 1 && indexPath.row == 0 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            // "앱 버전" 라벨을 추가
            let versionLabel = UILabel()
            versionLabel.text = "앱 버전"
            cell.contentView.addSubview(versionLabel)
            versionLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                versionLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20),
                versionLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
            ])
            
            // 앱 버전 번호를 추가 (예: "1.0")
            let appVersionLabel = UILabel()
            appVersionLabel.text = "1.0"
            cell.contentView.addSubview(appVersionLabel)
            appVersionLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                appVersionLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -20),
                appVersionLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
            ])
            
            return cell
        }
        
        else if indexPath.section == 1 && indexPath.row == 1 {
                let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                // "개발자 연락처" 라벨을 추가
                let label = UILabel()
                label.text = "개발자 연락처"
                cell.contentView.addSubview(label)
                label.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    label.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20),
                    label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
                ])
                
                // 이메일을 추가
                let emailLabel = UILabel()
                emailLabel.text = "wlsgurrla716@icolud.com"
                cell.contentView.addSubview(emailLabel)
                emailLabel.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    emailLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -20),
                    emailLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
                ])
                
                return cell
            }
        
        
        else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            // Configure other cells as needed
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 1 {
            // 예시 이메일 주소
            let emailAddress = "wlsgurrla716@icolud.com"
            
            // 이메일 주소를 NSURL 형식으로 변환
            if let url = URL(string: "mailto:\(emailAddress)") {
                // 메일 앱 열기
                UIApplication.shared.open(url)
            }
            
            // 선택한 셀의 선택 상태 해제
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    
    // 섹션
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "설정  (조식 - 8:30, 중식 - 11:30, 석식 - 17:30)"
        } else if section == 1 {
            return "앱 정보"
        } else {return ""}
    
}
    
}
