//
//  HouseViewController.swift
//  Menu
//
//  Created by 김진혁 on 1/16/24.
//

import UIKit

class HouseViewController: UIViewController {
    
    var tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    let data = [["학생회관_학생식당", "학생회관_자율식당", "예지학사_식당", "65번가_도서관지하분식점"]]
    let header = ["식당"]
    
    
    // meal
    let meal = MealType()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hexCode: "#222f3e")
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        navigationItem.title = "식당을 선택하세요"
        
        // Set navigation bar title text color to black
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(hexCode: "#c8d6e5")]
        
        applyConstraints()
        
    }
    
    
    // 테이블 오토 레이아웃
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
extension HouseViewController:  UITableViewDataSource, UITableViewDelegate {
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: .none)
        cell.textLabel?.textColor = UIColor(hexCode: "#c8d6e5") // 글자 색깔을 검은색으로 변경
        cell.backgroundColor = UIColor(hexCode: "#576574") // 셀 컬러를 하얀색으로
        
        cell.textLabel?.text = data[indexPath.section][indexPath.row]
        return cell
    }
    
    // 섹션
    func numberOfSections(in tableView: UITableView) -> Int {
        return header.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        
        return header[section]
    }
    
    
    // 열 선택
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            // 학생회관_학생식당 selected
            Data.navTitle = meal.mealType[0]
            navigationController?.popViewController(animated: true)
        case 1:
            // 학생회관_자율식당 selected
            Data.navTitle = meal.mealType[1]
            navigationController?.popViewController(animated: true)
        case 2:
            // 예지학사식당 selected
            // Handle as needed
            Data.navTitle = meal.mealType[2]
            navigationController?.popViewController(animated: true)
        case 3:
            // 세명식당 selected
            // Handle as needed
            Data.navTitle = meal.mealType[3]
            navigationController?.popViewController(animated: true)
        default:
            break
        }
        
    }
    
    
    // 섹션 글자색 변경
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
           // 섹션 헤더의 뷰가 표시될 때 호출되는 함수
           guard let header = view as? UITableViewHeaderFooterView else { return }
           
           // 섹션 헤더의 글자색 설정
           header.textLabel?.textColor = UIColor(hexCode: "#c8d6e5") // 변경하고자 하는 색상으로 설정
       }
    
    
   
}
