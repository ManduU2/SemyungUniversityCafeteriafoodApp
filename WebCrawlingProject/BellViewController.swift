//
//  BellViewController.swift
//  WebCrawlingProject
//
//  Created by 김진혁 on 3/8/24.
//

import UIKit
import FirebaseCore
import FirebaseFirestore

class BellViewController: UIViewController, UNUserNotificationCenterDelegate  {
    
    
    // 파이어스토어
    let db = Firestore.firestore()
    
    let switchStateKey = "SwitchState"
    
    
    var tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hexCode: "#222f3e")
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        
        
        navigationItem.title = "알림 설정"
        
       
        // Set navigation bar title text color to black
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(hexCode: "#c8d6e5")]
    
        
        
        applyConstraints()
        
        
        
       
        
    }
    
    
    fileprivate func applyConstraints() {
        self.view.addSubview(self.tableView)
        
        tableView.backgroundColor = UIColor(hexCode: "#222f3e")
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        
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
            switchCell.backgroundColor = UIColor(hexCode: "#576574") // 셀 컬러를 하얀색으로
            
            
            
            // Label
            let label = UILabel()
            label.text = "알림"
            label.textColor = UIColor(hexCode: "#c8d6e5")
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
            
            
            cell.backgroundColor = UIColor(hexCode: "#576574") // 셀 컬러를 하얀색으로
            
            // "앱 버전" 라벨을 추가
            let versionLabel = UILabel()
            versionLabel.text = "앱 버전"
            versionLabel.textColor = UIColor(hexCode: "#c8d6e5")
            cell.contentView.addSubview(versionLabel)
            versionLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                versionLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20),
                versionLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
            ])
            
            // 앱 버전 번호를 추가 (예: "1.0")
            let appVersionLabel = UILabel()
            // 현재 앱 버전 확인
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
            appVersionLabel.text = version
            appVersionLabel.textColor = UIColor(hexCode: "#c8d6e5")
            
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
            
            cell.textLabel?.textColor = UIColor(hexCode: "#c8d6e5") // 글자 색깔을 검은색으로 변경
            cell.backgroundColor = UIColor(hexCode: "#576574") // 셀 컬러를 하얀색으로
            
            // "개발자 연락처" 라벨을 추가
            let label = UILabel()
            label.text = "개발자 연락처"
            label.textColor = UIColor(hexCode: "#c8d6e5")
            cell.contentView.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20),
                label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
            ])
            
            // 이메일을 추가
            let emailLabel = UILabel()
            emailLabel.text = "wlsgurrla716@icolud.com"
            emailLabel.textColor = UIColor(hexCode: "#c8d6e5")
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
            
            cell.textLabel?.textColor = UIColor(hexCode: "#c8d6e5") // 글자 색깔을 검은색으로 변경
            cell.backgroundColor = UIColor(hexCode: "#576574") // 셀 컬러를 하얀색으로
            
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.cellForRow(at: indexPath)?.selectionStyle = .none
        
        
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
    
    // 섹션 글자색 변경
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
           // 섹션 헤더의 뷰가 표시될 때 호출되는 함수
           guard let header = view as? UITableViewHeaderFooterView else { return }
           
           // 섹션 헤더의 글자색 설정
           header.textLabel?.textColor = UIColor(hexCode: "#c8d6e5") // 변경하고자 하는 색상으로 설정
       }
    
    
    
}
