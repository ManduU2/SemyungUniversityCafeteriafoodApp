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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        navigationItem.title = "식당을 선택하세요"
        
        applyConstraints()
        
    }
    
    
    // 테이블 오토 레이아웃
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
    
}







// 테이블 델리게이트
extension HouseViewController:  UITableViewDataSource, UITableViewDelegate {
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: .none)
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
            Data.navTitle = "식단표 (학생회관_학생식당)"
            navigationController?.popViewController(animated: true)
        case 1:
            // 학생회관_자율식당 selected
            Data.navTitle = "식단표 (학생회관_자율식당)"
            navigationController?.popViewController(animated: true)
        case 2:
            // 예지학사식당 selected
            // Handle as needed
            Data.navTitle = "식단표 (예지학사_식당)"
            navigationController?.popViewController(animated: true)
        case 3:
            // 세명식당 selected
            // Handle as needed
            Data.navTitle = "식단표 (65번가_도서관지하분식점)"
            navigationController?.popViewController(animated: true)
        default:
            break
        }
        
    }
    
    
    
}
