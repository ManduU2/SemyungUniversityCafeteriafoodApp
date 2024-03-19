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
    
    

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
    
        navigationItem.title = "알림 설정"
        
      
        
        applyConstraints()
        
        
    }
    
    fileprivate func applyConstraints() {
        self.view.addSubview(self.tableView)
        
        tableView.backgroundColor = .systemGray2
        
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
            switchCell.backgroundColor = .white // 셀 컬러를 하얀색으로
            
            
            
            // Label
            let label = UILabel()
            label.text = "알림"
            label.textColor = .black
            switchCell.contentView.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: switchCell.contentView.leadingAnchor, constant: 20),
                label.centerYAnchor.constraint(equalTo: switchCell.contentView.centerYAnchor)
            ])
            
            
            

            
      
            
            return switchCell
        }
        
        
        else if indexPath.section == 1 && indexPath.row == 0 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            
            
            cell.backgroundColor = .white // 셀 컬러를 하얀색으로
            
            // "앱 버전" 라벨을 추가
            let versionLabel = UILabel()
            versionLabel.text = "앱 버전"
            versionLabel.textColor = .black
            cell.contentView.addSubview(versionLabel)
            versionLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                versionLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20),
                versionLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
            ])
            
            // 앱 버전 번호를 추가 (예: "1.0")
            let appVersionLabel = UILabel()
            appVersionLabel.text = "1.0"
            appVersionLabel.textColor = .black
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
            
            cell.textLabel?.textColor = .black // 글자 색깔을 검은색으로 변경
            cell.backgroundColor = .white // 셀 컬러를 하얀색으로
            
            // "개발자 연락처" 라벨을 추가
            let label = UILabel()
            label.text = "개발자 연락처"
            label.textColor = .black
            cell.contentView.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20),
                label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
            ])
            
            // 이메일을 추가
            let emailLabel = UILabel()
            emailLabel.text = "wlsgurrla716@icolud.com"
            emailLabel.textColor = .black
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
            
            cell.textLabel?.textColor = .black // 글자 색깔을 검은색으로 변경
            cell.backgroundColor = .white // 셀 컬러를 하얀색으로
            
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if indexPath.section == 0 && indexPath.row == 0 {
                // 알림 셀이 선택된 경우 설정 앱으로 이동
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
                tableView.deselectRow(at: indexPath, animated: true)
            }
        
        
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
