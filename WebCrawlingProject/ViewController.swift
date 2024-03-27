//
//  ViewController.swift
//  WebCrawlingProject
//
//  Created by 김진혁 on 3/4/24.
//

/*
 
 <알림> 유심히 보기
 
 
 
 <완료>
 1.0.3 ->
 1. 앱 버전이 정확하게 나타나게 수정완료.
 2. header에 조식, 중식, 석식 시간 표기하기 -> 시간은 다음 버전에서 하기(식사시간이 확실하지 않음)
 UIColor 전부 수정하기 (팔레트 이용)
 좋아요, 싫어요 버튼을 탭할때 알림(눌렸다, 취소됐다)창이 나오도록 변경?
 
 
 1.0.4 ->
 
 1. 위젯 구현 완료
 2. 개발자 이메일 오타 수정
 3. 최적화 완료.
 
 */
/*
 <예정>
 
 알림 버그 수정 (앱을 작동하지 않으면 알림에서 전 기록의 알림이 발송됨)
 
 
 
 
 
 */



//

import UIKit
import FSCalendar
import FirebaseCore
import FirebaseFirestore




class ViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, UITextFieldDelegate {
    
    
    
    
    // 파이어베이스
    let db = Firestore.firestore()
    
    private let calendar: FSCalendar = {
        let calendar = FSCalendar(frame: .zero)
        
        calendar.headerHeight = 50
        calendar.weekdayHeight = 20
        
        // 주간 달력 설정
        calendar.scope = .week
        
        // 텍스트 컬러 설정
        calendar.appearance.headerTitleColor = UIColor(hexCode: "#c8d6e5")
        calendar.appearance.weekdayTextColor = UIColor(hexCode: "#c8d6e5")
        calendar.appearance.selectionColor = UIColor(hexCode: "#ff9ff3")
        calendar.appearance.todayColor = UIColor(hexCode: "#feca57")
        calendar.backgroundColor = UIColor(hexCode: "#222f3e") //calendarColor
        
        // 요일 설정 (한국어)
        calendar.locale = Locale(identifier: "ko_KR")
        
        // 월 표시 나오도록 설정
        calendar.appearance.headerDateFormat = "yyyy년 MM월" // 월의 축약 형태로 표시
        
        
        
        
        return calendar
    }()
    
    
    
    // 식단 테이블
    var tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    
    
    // 식단 테이블을 위한 데이터
    var data: [[String]] = [[""], [""], [""]]
    let header = ["조식","중식","석식"]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendar.delegate = self
        calendar.dataSource = self
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        view.backgroundColor = UIColor(hexCode: "#222f3e") // backgroundColor

        
        self.navigationItem.title = ""
        
        // 앱이 백그라운드에 있을 때도 실행되도록 백그라운드 작업을 등록합니다.
        registerBackgroundTask()
        
        configureItems()
        applyConstraints()
        
    }
    
    
    // 풀 스크린이 아니면 viewWillAppear이 실행되지를 않음
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 현재 날짜 데이터 포맷
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let current_date_string = formatter.string(from: Date())
        
        
        // 이렇게 넣으면 타입 저장 속성에 계속해서 현재 날짜가 기입됨
        Data.currentDateStringSpace = current_date_string
        
        
        self.title = Data.navTitle
        
        // Set navigation bar title text color to black
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(hexCode: "#c8d6e5")]
        
        
        
        dateNow()
    }
    
    
    // 뷰가 끝나는 시점
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // 캘린더의 선택된 날짜 색 초기화
        if let selectedDate = self.calendar.selectedDate {
            self.calendar.deselect(selectedDate)
        }
        
    }
    
    
    // 백그라운드 작업을 등록합니다.
        func registerBackgroundTask() {
            DispatchQueue.global(qos: .background).async {
                // 특정 시간에 코드를 실행하는 함수를 호출합니다.
                self.scheduleTask()
                
                // 백그라운드 작업이 완료되었음을 시스템에 알립니다.
                UIApplication.shared.endBackgroundTask(UIBackgroundTaskIdentifier(rawValue: .max))
            }
        }
    
    
    // 이걸 델리게이트에 넣어야할꺼 같음.
    // 특정 시간에 코드를 실행합니다.
        func scheduleTask() {
            // 예를 들어, 오늘 자정에 코드를 실행하려면 다음과 같이 할 수 있습니다.
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
            components.hour = 23
            components.minute = 30
            
            let midnight = calendar.date(from: components)!
            
            let notificationContent = UNMutableNotificationContent()
            //notificationContent.title = "자동 실행"
            //notificationContent.body = "앱이 자동으로 실행됩니다."
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: calendar.dateComponents([.hour, .minute], from: midnight), repeats: true)
            
            let request = UNNotificationRequest(identifier: "AutoRunNotification", content: notificationContent, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { (error) in
                if let error = error {
                    print("알림 요청 실패: \(error.localizedDescription)")
                } else {
                    print("알림 요청 성공")
                    
                }
            }
        }
    
    
    
    
    
    // 네비게이션 바 아이템
    private func configureItems() {
        
        
        
        
        // Custom hamburger button image (left)
        let hamburgerImage = UIImage(systemName: "line.horizontal.3")! as UIImage
        let blueHamburgerImage = hamburgerImage.imageWithColor(color: UIColor(hexCode: "#636e72"))
        
        
        
        // Custom bell button image (right)
        let gearImage = UIImage(systemName: "gearshape.fill")! as UIImage
        let bluegearImage = gearImage.imageWithColor(color: UIColor(hexCode: "#636e72"))
        
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: blueHamburgerImage,
            style: .plain,
            target: self,
            action: #selector(houseButtonTapped)
        )
        
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: bluegearImage,
            style: .plain,
            target: self,
            action: #selector(bellButtonTapped)
        )
        
        
        
    }
    
    
    fileprivate func applyConstraints() {
        view.addSubview(calendar)
        self.view.addSubview(self.tableView)
        tableView.backgroundColor = UIColor(hexCode: "#222f3e") // tableColor
        
        
        
        calendar.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        
        
        let calendarConstraints = [
            calendar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            calendar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            calendar.topAnchor.constraint(equalTo: view.topAnchor, constant: 120), // 조정된 위치
            calendar.heightAnchor.constraint(equalToConstant: 200) // 조정된 높이
        ]
        
        
        NSLayoutConstraint.activate(calendarConstraints)
        
        
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 170),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        
        
    }
    
    
    // 날짜 선택
    internal func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition)  {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        //print("날짜 선택 : " + dateFormatter.string(from: date))
        
        Data.currentDateStringSpace = dateFormatter.string(from: date)
        
        if Data.navTitle == "식단표 (학생회관_학생식당)" {
            
            let docRef = db.collection("Menu").document(dateFormatter.string(from: date))
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let 아침메뉴 = document.data()?["아침메뉴"] as? String {
                        
                        let 아침메뉴 = 아침메뉴.replacingOccurrences(of: "\\n", with: "\n")
                        
                        docRef.getDocument { (document, error) in
                            if let document = document, document.exists {
                                if let 점심메뉴 = document.data()?["점심메뉴"] as? String {
                                    let 점심메뉴 = 점심메뉴.replacingOccurrences(of: "\\n", with: "\n")
                                    
                                    docRef.getDocument { (document, error) in
                                        if let document = document, document.exists {
                                            if let 저녁메뉴 = document.data()?["저녁메뉴"] as? String {
                                                let 저녁메뉴 = 저녁메뉴.replacingOccurrences(of: "\\n", with: "\n")
                                                self.data = [[아침메뉴],
                                                             [점심메뉴],
                                                             [저녁메뉴]]
                                                self.tableView.reloadData()
                                                
                                            }
                                        }
                                    }
                                    
                                }
                            }
                        }
                        

                        
                    } else {
                        print("아침메뉴가 없습니다.")
                    }
                } else {
                    self.data = [["아직 식단이 등록되지 않았습니다."],
                                 ["아직 식단이 등록되지 않았습니다."],
                                 ["아직 식단이 등록되지 않았습니다."]]
                    self.tableView.reloadData()
                }
            }
            
            self.tableView.reloadData()
            
        }
        
        
        if Data.navTitle == "식단표 (학생회관_자율식당)" {
            
            let docRef = db.collection("Menu2").document(dateFormatter.string(from: date))
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let 아침메뉴 = document.data()?["아침메뉴"] as? String {
                        let 아침메뉴 = 아침메뉴.replacingOccurrences(of: "\\n", with: "\n")
                        
                        docRef.getDocument { (document, error) in
                            if let document = document, document.exists {
                                if let 점심메뉴 = document.data()?["점심메뉴"] as? String {
                                    let 점심메뉴 = 점심메뉴.replacingOccurrences(of: "\\n", with: "\n")
                                    
                                    docRef.getDocument { (document, error) in
                                        if let document = document, document.exists {
                                            if let 저녁메뉴 = document.data()?["저녁메뉴"] as? String {
                                                let 저녁메뉴 = 저녁메뉴.replacingOccurrences(of: "\\n", with: "\n")
                                                
                                                self.data = [[아침메뉴],
                                                             [점심메뉴],
                                                             [저녁메뉴]]
                                                self.tableView.reloadData()
                                            }
                                        }
                                    }
                                    
                                }
                            }
                        }
                        
                        
                        
                    } else {
                        print("아침메뉴가 없습니다.")
                    }
                } else {
                    self.data = [["아직 식단이 등록되지 않았습니다."],
                                 ["아직 식단이 등록되지 않았습니다."],
                                 ["아직 식단이 등록되지 않았습니다."]]
                    self.tableView.reloadData()
                }
            }
            
            self.tableView.reloadData()
            
        }
        
        
        if Data.navTitle == "식단표 (예지학사_식당)" {
            
            let docRef = db.collection("Menu3").document(dateFormatter.string(from: date))
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let 아침메뉴 = document.data()?["아침메뉴"] as? String {
                        let 아침메뉴 = 아침메뉴.replacingOccurrences(of: "\\n", with: "\n")
                        
                        docRef.getDocument { (document, error) in
                            if let document = document, document.exists {
                                if let 점심메뉴 = document.data()?["점심메뉴"] as? String {
                                    let 점심메뉴 = 점심메뉴.replacingOccurrences(of: "\\n", with: "\n")
                                    
                                    docRef.getDocument { (document, error) in
                                        if let document = document, document.exists {
                                            if let 저녁메뉴 = document.data()?["저녁메뉴"] as? String {
                                                let 저녁메뉴 = 저녁메뉴.replacingOccurrences(of: "\\n", with: "\n")
                                                
                                                self.data = [[아침메뉴],
                                                             [점심메뉴],
                                                             [저녁메뉴]]
                                                self.tableView.reloadData()
                                            }
                                        }
                                    }
                                    
                                }
                            }
                        }
                        
                        
                        
                    } else {
                        print("아침메뉴가 없습니다.")
                    }
                } else {
                    self.data = [["아직 식단이 등록되지 않았습니다."],
                                 ["아직 식단이 등록되지 않았습니다."],
                                 ["아직 식단이 등록되지 않았습니다."]]
                    self.tableView.reloadData()
                }
            }
            
            self.tableView.reloadData()
            
        }
        
        
        if Data.navTitle == "식단표 (65번가_도서관지하분식점)" {
            
            let docRef = db.collection("Menu4").document(dateFormatter.string(from: date))
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let 아침메뉴 = document.data()?["아침메뉴"] as? String {
                        let 아침메뉴 = 아침메뉴.replacingOccurrences(of: "\\n", with: "\n")
                        
                        docRef.getDocument { (document, error) in
                            if let document = document, document.exists {
                                if let 점심메뉴 = document.data()?["점심메뉴"] as? String {
                                    let 점심메뉴 = 점심메뉴.replacingOccurrences(of: "\\n", with: "\n")
                                    
                                    docRef.getDocument { (document, error) in
                                        if let document = document, document.exists {
                                            if let 저녁메뉴 = document.data()?["저녁메뉴"] as? String {
                                                let 저녁메뉴 = 저녁메뉴.replacingOccurrences(of: "\\n", with: "\n")
                                                
                                                self.data = [[아침메뉴],
                                                             [점심메뉴],
                                                             [저녁메뉴]]
                                                self.tableView.reloadData()
                                            }
                                        }
                                    }
                                    
                                }
                            }
                        }
                        
                        
                        
                    } else {
                        print("아침메뉴가 없습니다.")
                    }
                } else {
                    self.data = [["아직 식단이 등록되지 않았습니다."],
                                 ["아직 식단이 등록되지 않았습니다."],
                                 ["아직 식단이 등록되지 않았습니다."]]
                    self.tableView.reloadData()
                }
            }
            
            self.tableView.reloadData()
            
        }
        
        
    }
    
    
    
    
    
    func dateNow() {
        
        
        let loadingView = UIView(frame: view.bounds)
        loadingView.backgroundColor = UIColor.lightGray
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = loadingView.center
        loadingView.addSubview(activityIndicator)
        view.addSubview(loadingView)
        activityIndicator.startAnimating()
        
        
        // 현재 날짜 데이터 포맷
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let current_date_string = formatter.string(from: Date())
        
        
        
        if Data.navTitle == "식단표 (학생회관_학생식당)" {
            let docRef = db.collection("Menu").document(current_date_string)
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let 아침메뉴 = document.data()?["아침메뉴"] as? String {
                        let 아침메뉴 = 아침메뉴.replacingOccurrences(of: "\\n", with: "\n")
                        
                        docRef.getDocument { (document, error) in
                            if let document = document, document.exists {
                                if let 점심메뉴 = document.data()?["점심메뉴"] as? String {
                                    let 점심메뉴 = 점심메뉴.replacingOccurrences(of: "\\n", with: "\n")
                                    
                                    docRef.getDocument { (document, error) in
                                        if let document = document, document.exists {
                                            if let 저녁메뉴 = document.data()?["저녁메뉴"] as? String {
                                                let 저녁메뉴 = 저녁메뉴.replacingOccurrences(of: "\\n", with: "\n")
                                                
                                                
                                                
                                                self.data = [[아침메뉴],
                                                             [점심메뉴],
                                                             [저녁메뉴]]
                                                
                                                // 이곳이 데이터 로딩이 끝내는 함수
                                                activityIndicator.stopAnimating()
                                                loadingView.removeFromSuperview()
                                                
                                                
                                                self.tableView.reloadData()
                                                
                                                
                                                
                                                
                                            }
                                        }
                                    }
                                    
                                }
                            }
                        }
                        
                        
                        
                    } else {
                        print("아침메뉴가 없습니다.")
                    }
                } else {
                    self.data = [["아직 식단이 등록되지 않았습니다."],
                                 ["아직 식단이 등록되지 않았습니다."],
                                 ["아직 식단이 등록되지 않았습니다."]]
                    // 이곳이 데이터 로딩이 끝내는 함수
                    activityIndicator.stopAnimating()
                    loadingView.removeFromSuperview()
                    self.tableView.reloadData()
                }
            }
            self.tableView.reloadData()
            
            
        }
        
        
        if Data.navTitle == "식단표 (학생회관_자율식당)" {
            let docRef = db.collection("Menu2").document(current_date_string)
            
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let 아침메뉴 = document.data()?["아침메뉴"] as? String {
                        let 아침메뉴 = 아침메뉴.replacingOccurrences(of: "\\n", with: "\n")
                        
                        
                        docRef.getDocument { (document, error) in
                            if let document = document, document.exists {
                                if let 점심메뉴 = document.data()?["점심메뉴"] as? String {
                                    let 점심메뉴 = 점심메뉴.replacingOccurrences(of: "\\n", with: "\n")
                                    
                                    docRef.getDocument { (document, error) in
                                        if let document = document, document.exists {
                                            if let 저녁메뉴 = document.data()?["저녁메뉴"] as? String {
                                                let 저녁메뉴 = 저녁메뉴.replacingOccurrences(of: "\\n", with: "\n")
                                                
                                                
                                                self.data = [[아침메뉴],
                                                             [점심메뉴],
                                                             [저녁메뉴]]
                                                self.tableView.reloadData()
                                                
                                                activityIndicator.stopAnimating()
                                                loadingView.removeFromSuperview()
                                            }
                                        }
                                    }
                                    
                                }
                            }
                        }
                        
                        
                        
                    } else {
                        print("아침메뉴가 없습니다.")
                    }
                } else {
                    self.data = [["아직 식단이 등록되지 않았습니다."],
                                 ["아직 식단이 등록되지 않았습니다."],
                                 ["아직 식단이 등록되지 않았습니다."]]
                    // 이곳이 데이터 로딩이 끝내는 함수
                    activityIndicator.stopAnimating()
                    loadingView.removeFromSuperview()
                    self.tableView.reloadData()
                }
            }
            self.tableView.reloadData()
        }
        
        
        if Data.navTitle == "식단표 (예지학사_식당)" {
            let docRef = db.collection("Menu3").document(current_date_string)
            
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let 아침메뉴 = document.data()?["아침메뉴"] as? String {
                        let 아침메뉴 = 아침메뉴.replacingOccurrences(of: "\\n", with: "\n")
                        
                        
                        docRef.getDocument { (document, error) in
                            if let document = document, document.exists {
                                if let 점심메뉴 = document.data()?["점심메뉴"] as? String {
                                    let 점심메뉴 = 점심메뉴.replacingOccurrences(of: "\\n", with: "\n")
                                    
                                    docRef.getDocument { (document, error) in
                                        if let document = document, document.exists {
                                            if let 저녁메뉴 = document.data()?["저녁메뉴"] as? String {
                                                let 저녁메뉴 = 저녁메뉴.replacingOccurrences(of: "\\n", with: "\n")
                                                
                                                
                                                self.data = [[아침메뉴],
                                                             [점심메뉴],
                                                             [저녁메뉴]]
                                                self.tableView.reloadData()
                                                
                                                // 이곳이 데이터 로딩이 끝내는 함수
                                                activityIndicator.stopAnimating()
                                                loadingView.removeFromSuperview()
                                                self.tableView.reloadData()
                                            }
                                        }
                                    }
                                    
                                }
                            }
                        }
                        
                        
                        
                    } else {
                        print("아침메뉴가 없습니다.")
                    }
                } else {
                    self.data = [["아직 식단이 등록되지 않았습니다."],
                                 ["아직 식단이 등록되지 않았습니다."],
                                 ["아직 식단이 등록되지 않았습니다."]]
                    // 이곳이 데이터 로딩이 끝내는 함수
                    activityIndicator.stopAnimating()
                    loadingView.removeFromSuperview()
                    self.tableView.reloadData()
                }
            }
            self.tableView.reloadData()
        }
        
        
        if Data.navTitle == "식단표 (65번가_도서관지하분식점)" {
            let docRef = db.collection("Menu4").document(current_date_string)
            
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let 아침메뉴 = document.data()?["아침메뉴"] as? String {
                        let 아침메뉴 = 아침메뉴.replacingOccurrences(of: "\\n", with: "\n")
                        
                        
                        docRef.getDocument { (document, error) in
                            if let document = document, document.exists {
                                if let 점심메뉴 = document.data()?["점심메뉴"] as? String {
                                    let 점심메뉴 = 점심메뉴.replacingOccurrences(of: "\\n", with: "\n")
                                    
                                    docRef.getDocument { (document, error) in
                                        if let document = document, document.exists {
                                            if let 저녁메뉴 = document.data()?["저녁메뉴"] as? String {
                                                let 저녁메뉴 = 저녁메뉴.replacingOccurrences(of: "\\n", with: "\n")
                                                
                                                
                                                self.data = [[아침메뉴],
                                                             [점심메뉴],
                                                             [저녁메뉴]]
                                                self.tableView.reloadData()
                                                
                                                // 이곳이 데이터 로딩이 끝내는 함수
                                                activityIndicator.stopAnimating()
                                                loadingView.removeFromSuperview()
                                                self.tableView.reloadData()
                                            }
                                        }
                                    }
                                    
                                }
                            }
                        }
                        
                        
                        
                    } else {
                        print("아침메뉴가 없습니다.")
                    }
                } else {
                    self.data = [["아직 식단이 등록되지 않았습니다."],
                                 ["아직 식단이 등록되지 않았습니다."],
                                 ["아직 식단이 등록되지 않았습니다."]]
                    // 이곳이 데이터 로딩이 끝내는 함수
                    activityIndicator.stopAnimating()
                    loadingView.removeFromSuperview()
                    self.tableView.reloadData()
                }
            }
            self.tableView.reloadData()
        }
        
        
        
    }
    
    // 왼쪽 식당(햄버거 메뉴) 선택
    @objc private func houseButtonTapped() {
        let vc = HouseViewController()
        
        // backButton
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil) // title 부분 수정
        backBarButtonItem.tintColor = UIColor(hexCode: "#c8d6e5")
        self.navigationItem.backBarButtonItem = backBarButtonItem
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // 오른쪽 알림(종) 선택
    @objc private func bellButtonTapped() {
        let vc = BellViewController()
        
        // backButton
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil) // title 부분 수정
        backBarButtonItem.tintColor = UIColor(hexCode: "#c8d6e5")
        self.navigationItem.backBarButtonItem = backBarButtonItem
        
        navigationController?.pushViewController(vc, animated: true)
    }
}






// 테이블 델리게이트 설정
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    // 섹션 수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let likeButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("👍", for: .normal)
            
            button.addTarget(self, action: #selector(likeButtonTapped(_:)), for: .touchUpInside)
            button.tag = indexPath.row // Set tag to identify the button
            return button
        }()
        
        let dislikeButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("👎", for: .normal)
            
            button.addTarget(self, action: #selector(dislikeButtonTapped(_:)), for: .touchUpInside)
            button.tag = indexPath.row // Set tag to identify the button
            
            return button
        }()
        
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: .none)
        
        
        // 현재 날짜 데이터 포맷
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let current_date_string = formatter.string(from: Date())
        
        
        
        cell.backgroundColor = UIColor(hexCode: "#576574") // cellColor
        cell.textLabel?.numberOfLines = 0 // 줄바꿈 설정
        cell.textLabel?.textColor = UIColor(hexCode: "#c8d6e5") // tintColor
        cell.textLabel?.text = data[indexPath.section][indexPath.row]
        
        
        
        let likeCountLabel = UILabel()
        let dislikeCountLabel = UILabel()
        
        
        // 파이어베이스 [데이터 불러오기] (임시)
        let mealType: String
        switch indexPath.section {
        case 0:
            mealType = "아침메뉴Like"
        case 1:
            mealType = "점심메뉴Like"
        case 2:
            mealType = "저녁메뉴Like"
        default:
            mealType = ""
        }
        
        
        
        let dismealType: String
        switch indexPath.section {
        case 0:
            dismealType = "아침메뉴DisLike"
        case 1:
            dismealType = "점심메뉴DisLike"
        case 2:
            dismealType = "저녁메뉴DisLike"
        default:
            dismealType = ""
        }
        
        
        
        // 파이어베이스 [데이터 불러오기]
        
        if Data.navTitle == "식단표 (학생회관_학생식당)" {
            
            let docRef = db.collection("Menu").document(Data.currentDateStringSpace)
            
            
            //
            //////
            //
            //            docRef.getDocument { (document, error) in
            //                if let document = document, document.exists {
            //                    if let like = document.data()?[mealType] as? String {
            //                        likeCountLabel.text = like
            //                        likeCountLabel.textColor = .red
            //                        likeCountLabel.tag = 1000 // Set tag for identification
            //
            //                    }
            //
            //                }
            //                else {
            //                    print("   2   ")
            //                }
            //
            //            }
            
            
            
            // 이쪽 중요
            // 데이터 변경 사항을 수신하는 메서드 // 기기로 한 번 테스트
            docRef.addSnapshotListener { (document, error) in
                guard let document = document else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                if document.exists {
                    if let like = document.data()?[mealType] as? String {
                        likeCountLabel.text = like
                        likeCountLabel.textColor = UIColor(hexCode: "#ee5253")
                        likeCountLabel.tag = 1000 // Set tag for identification
                    }
                } else {
                    print("Document does not exist")
                }
            }
            
            
            
            docRef.addSnapshotListener { (document, error) in
                guard let document = document else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                if document.exists {
                    if let like = document.data()?[dismealType] as? String {
                        dislikeCountLabel.text = like
                        dislikeCountLabel.textColor = UIColor(hexCode: "#0abde3")
                        dislikeCountLabel.tag = 2000 // Set tag for identification
                    }
                } else {
                    print("Document does not exist")
                }
            }
            
            
            
//            docRef.getDocument { (document, error) in
//                if let document = document, document.exists {
//                    if let like = document.data()?[dismealType] as? String {
//                        dislikeCountLabel.text = like
//                        dislikeCountLabel.textColor = .systemBlue
//                        dislikeCountLabel.tag = 2000 // Set tag for identification
//                        
//                    }
//                    
//                }
//                else {
//                    print("   2   ")
//                }
//            }
            
            
            
            
        }
        
        if Data.navTitle == "식단표 (학생회관_자율식당)" {
            
            let docRef = db.collection("Menu2").document(Data.currentDateStringSpace)
            
            
//            docRef.getDocument { (document, error) in
//                if let document = document, document.exists {
//                    if let like = document.data()?[mealType] as? String {
//                        likeCountLabel.text = like
//                        likeCountLabel.textColor = .red
//                        likeCountLabel.tag = 1000 // Set tag for identification
//                    }
//                }
//                else {
//                    print("   2   ")
//                }
//                
//            }
//            
//            docRef.getDocument { (document, error) in
//                if let document = document, document.exists {
//                    if let like = document.data()?[dismealType] as? String {
//                        dislikeCountLabel.text = like
//                        dislikeCountLabel.textColor = .systemBlue
//                        dislikeCountLabel.tag = 2000 // Set tag for identification
//                    }
//                }
//                else {
//                    print("   2   ")
//                }
//                
//            }
            
            // 이쪽 중요
            // 데이터 변경 사항을 수신하는 메서드 // 기기로 한 번 테스트
            docRef.addSnapshotListener { (document, error) in
                guard let document = document else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                if document.exists {
                    if let like = document.data()?[mealType] as? String {
                        likeCountLabel.text = like
                        likeCountLabel.textColor = .red
                        likeCountLabel.tag = 1000 // Set tag for identification
                    }
                } else {
                    print("Document does not exist")
                }
            }
            
            
            
            docRef.addSnapshotListener { (document, error) in
                guard let document = document else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                if document.exists {
                    if let like = document.data()?[dismealType] as? String {
                        dislikeCountLabel.text = like
                        dislikeCountLabel.textColor = .systemBlue
                        dislikeCountLabel.tag = 2000 // Set tag for identification
                    }
                } else {
                    print("Document does not exist")
                }
            }
            
            
        }
        
        if Data.navTitle == "식단표 (예지학사_식당)" {
            
            let docRef = db.collection("Menu3").document(Data.currentDateStringSpace)
            
            
//            docRef.getDocument { (document, error) in
//                if let document = document, document.exists {
//                    if let like = document.data()?[mealType] as? String {
//                        likeCountLabel.text = like
//                        likeCountLabel.textColor = .red
//                        likeCountLabel.tag = 1000 // Set tag for identification
//                    }
//                }
//                else {
//                    print("   2   ")
//                }
//                
//            }
//            
//            docRef.getDocument { (document, error) in
//                if let document = document, document.exists {
//                    if let like = document.data()?[dismealType] as? String {
//                        dislikeCountLabel.text = like
//                        dislikeCountLabel.textColor = .systemBlue
//                        dislikeCountLabel.tag = 2000 // Set tag for identification
//                    }
//                }
//                else {
//                    print("   2   ")
//                }
//                
//            }
            
            // 이쪽 중요
            // 데이터 변경 사항을 수신하는 메서드 // 기기로 한 번 테스트
            docRef.addSnapshotListener { (document, error) in
                guard let document = document else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                if document.exists {
                    if let like = document.data()?[mealType] as? String {
                        likeCountLabel.text = like
                        likeCountLabel.textColor = .red
                        likeCountLabel.tag = 1000 // Set tag for identification
                    }
                } else {
                    print("Document does not exist")
                }
            }
            
            
            
            docRef.addSnapshotListener { (document, error) in
                guard let document = document else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                if document.exists {
                    if let like = document.data()?[dismealType] as? String {
                        dislikeCountLabel.text = like
                        dislikeCountLabel.textColor = .systemBlue
                        dislikeCountLabel.tag = 2000 // Set tag for identification
                    }
                } else {
                    print("Document does not exist")
                }
            }
            
            
        }
        
        if Data.navTitle == "식단표 (65번가_도서관지하분식점)" {
            
            let docRef = db.collection("Menu4").document(Data.currentDateStringSpace)
            
            
//            docRef.getDocument { (document, error) in
//                if let document = document, document.exists {
//                    if let like = document.data()?[mealType] as? String {
//                        likeCountLabel.text = like
//                        likeCountLabel.textColor = .red
//                        likeCountLabel.tag = 1000 // Set tag for identification
//                    }
//                }
//                else {
//                    print("   2   ")
//                }
//                
//            }
//            
//            docRef.getDocument { (document, error) in
//                if let document = document, document.exists {
//                    if let like = document.data()?[dismealType] as? String {
//                        dislikeCountLabel.text = like
//                        dislikeCountLabel.textColor = .systemBlue
//                        dislikeCountLabel.tag = 2000 // Set tag for identification
//                    }
//                }
//                else {
//                    print("   2   ")
//                }
//                
//            }
            
            
            // 이쪽 중요
            // 데이터 변경 사항을 수신하는 메서드 // 기기로 한 번 테스트
            docRef.addSnapshotListener { (document, error) in
                guard let document = document else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                if document.exists {
                    if let like = document.data()?[mealType] as? String {
                        likeCountLabel.text = like
                        likeCountLabel.textColor = .red
                        likeCountLabel.tag = 1000 // Set tag for identification
                    }
                } else {
                    print("Document does not exist")
                }
            }
            
            
            
            docRef.addSnapshotListener { (document, error) in
                guard let document = document else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                if document.exists {
                    if let like = document.data()?[dismealType] as? String {
                        dislikeCountLabel.text = like
                        dislikeCountLabel.textColor = .systemBlue
                        dislikeCountLabel.tag = 2000 // Set tag for identification
                    }
                } else {
                    print("Document does not exist")
                }
            }
            
        }
        
        
        // Add labels to cell
        cell.contentView.addSubview(likeCountLabel)
        cell.contentView.addSubview(dislikeCountLabel)
        
        
        // Layout constraints for labels
        likeCountLabel.translatesAutoresizingMaskIntoConstraints = false
        dislikeCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        
        
        
        
        // Add buttons to cell
        cell.contentView.addSubview(likeButton)
        cell.contentView.addSubview(dislikeButton)
        
        
        
        // Layout constraints for buttons
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        dislikeButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            dislikeButton.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -20),
            dislikeButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            
            likeButton.trailingAnchor.constraint(equalTo: dislikeButton.leadingAnchor, constant: -10),
            likeButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
        ])
        
        NSLayoutConstraint.activate([
            likeButton.bottomAnchor.constraint(equalTo: likeCountLabel.topAnchor, constant: -5),
            likeCountLabel.centerXAnchor.constraint(equalTo: likeButton.centerXAnchor),
            
            dislikeButton.bottomAnchor.constraint(equalTo: dislikeCountLabel.topAnchor, constant: -5),
            dislikeCountLabel.centerXAnchor.constraint(equalTo: dislikeButton.centerXAnchor)
        ])
        
        
        // 값이 없는 셀에 좋아요, 싫어요 버튼을 제거
        if data[indexPath.section][indexPath.row] == "" || data[indexPath.section][indexPath.row] == "아직 식단이 등록되지 않았습니다." {
            likeCountLabel.isHidden = true
            likeButton.isHidden = true
            dislikeCountLabel.isHidden = true
            dislikeButton.isHidden = true
        } else {
            likeCountLabel.isHidden = false
            likeButton.isHidden = false
            dislikeCountLabel.isHidden = false
            dislikeButton.isHidden = false
        }
        
        
        
        
        return cell
    }
    
    
    
    @objc func likeButtonTapped(_ sender: UIButton) {
        
        // 버튼 탭 시 에니메이션 추가
        UIView.animate(withDuration: 0.2, animations: {
            // Scale the button to make it appear as if it's tapped
            sender.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { (_) in
            // After the animation completes, restore the original size
            UIView.animate(withDuration: 0.2) {
                sender.transform = .identity
            }
        }
        
        
        // 현재 날짜 데이터 포맷
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let current_date_string = formatter.string(from: Date())
        
        
        
        
        // Get the cell containing the button
        if let cell = sender.superview?.superview as? UITableViewCell,
           
            let indexPath = tableView.indexPath(for: cell) {
            
            
            let mealType2: String
            switch indexPath.section {
            case 0:
                mealType2 = "아침메뉴DisLike"
            case 1:
                mealType2 = "점심메뉴DisLike"
            case 2:
                mealType2 = "저녁메뉴DisLike"
            default:
                mealType2 = ""
            }
            
            
            
            
            let mealType: String
            switch indexPath.section {
            case 0:
                mealType = "아침메뉴Like"
            case 1:
                mealType = "점심메뉴Like"
            case 2:
                mealType = "저녁메뉴Like"
            default:
                mealType = ""
            }
            
            // 한 유저당 딱 좋아요를 한 번만 누를 수 있는 기능 (앱 삭제 후 실행시 까지는 해결못함)
            // UserDefaults에서 버튼 탭 히스토리를 가져옴 (이쪽에 대해서 한번 공식문서 봐보기)
            
            // forKey
            var buttonTapHistoryKey = "\(Data.navTitle)_\(mealType)_\(Data.currentDateStringSpace)"
            
            // forKey
            var buttonTapHistoryKey2 = "\(Data.navTitle)_\(mealType2)_\(Data.currentDateStringSpace)"
            
            
            
            
            
            var buttonTapHistory = UserDefaults.standard.dictionary(forKey: buttonTapHistoryKey) ?? [:]
            
            var buttonTapHistory2 = UserDefaults.standard.dictionary(forKey: buttonTapHistoryKey2) ?? [:]
            
            
            
            
            
            // 이미 탭한 적이 있는지 확인
            // 탭 한적이 있으면 1 감소, 없으면 1 증가
            
            if let tapped = buttonTapHistory["likeButtonTapped"] as? Bool, tapped {
                
                
                let alert = UIAlertController(title: "", message: "좋아요가 취소되셨습니다.", preferredStyle: .alert)
                
                
                present(alert, animated: true) {
                    // 문구가 1초뒤 사라지게 설정
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                           alert.dismiss(animated: true, completion: nil)
                       }
                }
                
                
                // 카운트 감소
                if let likeCountLabel = cell.contentView.viewWithTag(1000) as? UILabel {
                    
                    if Data.navTitle == "식단표 (학생회관_학생식당)" {
                        if let currentCount = Int(likeCountLabel.text ?? "0") {
                            
                            // 파이어베이스 [데이터 불러오기]
                            let docRef = self.db.collection("Menu").document(Data.currentDateStringSpace)
                            
                            docRef.getDocument { (document, error) in
                                if let document = document, document.exists {
                                    if let like = document.data()?[mealType] as? String {
                                        likeCountLabel.text = like
                                        
                                    }
                                    
                                }
                                
                                else {
                                    print("식단 메뉴가 등록되지 않았습니다.")
                                }
                                
                            }
                            
                            
                            // 파이어베이스에 like수를 올리기 (메뉴쪽 한 번 보기) 병합되게 설정 [데이터쓰기]
                            self.db.collection("Menu").document(Data.currentDateStringSpace).setData([ mealType: "\(currentCount - 1)" ], merge: true)
                            
                            
                            
                        }
                    }
                    
                    if Data.navTitle == "식단표 (학생회관_자율식당)" {
                        if let currentCount = Int(likeCountLabel.text ?? "0") {
                            
                            // 파이어베이스 [데이터 불러오기]
                            let docRef = self.db.collection("Menu2").document(Data.currentDateStringSpace)
                            
                            docRef.getDocument { (document, error) in
                                if let document = document, document.exists {
                                    if let like = document.data()?[mealType] as? String {
                                        likeCountLabel.text = like
                                        
                                        print("1")
                                    }
                                    
                                }
                                
                                else {
                                    print("   2   ")
                                }
                                
                            }
                            
                            
                            // 파이어베이스에 like수를 올리기 (메뉴쪽 한 번 보기) 병합되게 설정 [데이터쓰기]
                            self.db.collection("Menu2").document(Data.currentDateStringSpace).setData([ mealType: "\(currentCount - 1)" ], merge: true)
                            
                            
                            
                        }
                    }
                    
                    if Data.navTitle == "식단표 (예지학사_식당)" {
                        if let currentCount = Int(likeCountLabel.text ?? "0") {
                            
                            // 파이어베이스 [데이터 불러오기]
                            let docRef = self.db.collection("Menu3").document(Data.currentDateStringSpace)
                            
                            docRef.getDocument { (document, error) in
                                if let document = document, document.exists {
                                    if let like = document.data()?[mealType] as? String {
                                        likeCountLabel.text = like
                                        
                                        print("1")
                                    }
                                    
                                }
                                
                                else {
                                    print("   2   ")
                                }
                                
                            }
                            
                            
                            // 파이어베이스에 like수를 올리기 (메뉴쪽 한 번 보기) 병합되게 설정 [데이터쓰기]
                            self.db.collection("Menu3").document(Data.currentDateStringSpace).setData([ mealType: "\(currentCount - 1)" ], merge: true)
                            
                            
                            
                            
                            
                        }
                    }
                    
                    if Data.navTitle == "식단표 (65번가_도서관지하분식점)" {
                        if let currentCount = Int(likeCountLabel.text ?? "0") {
                            
                            // 파이어베이스 [데이터 불러오기]
                            let docRef = self.db.collection("Menu4").document(Data.currentDateStringSpace)
                            
                            docRef.getDocument { (document, error) in
                                if let document = document, document.exists {
                                    if let like = document.data()?[mealType] as? String {
                                        likeCountLabel.text = like
                                        
                                        print("1")
                                    }
                                    
                                }
                                
                                else {
                                    print("   2   ")
                                }
                                
                            }
                            
                            
                            // 파이어베이스에 like수를 올리기 (메뉴쪽 한 번 보기) 병합되게 설정 [데이터쓰기]
                            self.db.collection("Menu4").document(Data.currentDateStringSpace).setData([ mealType: "\(currentCount - 1)" ], merge: true)
                            
                            
                            
                        }
                    }
                    
                }
                
            
                // 버튼 탭 히스토리에 저장
                // 탭 히스토리 초기화
                buttonTapHistory = [:]
                UserDefaults.standard.set(buttonTapHistory, forKey: buttonTapHistoryKey)
                
                
                
            }
            
            
            
            else {
                
                let alert = UIAlertController(title: "", message: "좋아요를 선택하셨습니다.", preferredStyle: .alert)
                
                
                present(alert, animated: true) {
                    // 문구가 1초뒤 사라지게 설정
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                           alert.dismiss(animated: true, completion: nil)
                       }
                }
                
                
                //// (DisLike)를 이미 탭한 적이 있는지 확인
                /// DisLike를 탭한적이 있으면 싫어요 1 감소 좋아요 1증가
                if let DisLikeTappedCheck = buttonTapHistory2["dislikeButtonTapped"] as? Bool, DisLikeTappedCheck {
                    
                    
                    // 싫어요 카운트 감소
                    if let dislikeCountLabel = cell.contentView.viewWithTag(2000) as? UILabel {
                        
                        if Data.navTitle == "식단표 (학생회관_학생식당)" {
                            if let currentCount = Int(dislikeCountLabel.text ?? "0") {
                                
                                // 파이어베이스 [데이터 불러오기]
                                let docRef = self.db.collection("Menu").document(Data.currentDateStringSpace)
                                
                                docRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        if let like = document.data()?[mealType2] as? String {
                                            dislikeCountLabel.text = like
                                            
                                            
                                        }
                                        
                                    }
                                    
                                    else {
                                        print("   2   ")
                                    }
                                    
                                }
                                
                                
                                // 파이어베이스에 like수를 올리기 (메뉴쪽 한 번 보기) 병합되게 설정 [데이터쓰기]
                                self.db.collection("Menu").document(Data.currentDateStringSpace).setData([ mealType2: "\(currentCount - 1)" ], merge: true)
                                
                                print(current_date_string)
                                
                            }
                        }
                        
                        if Data.navTitle == "식단표 (학생회관_자율식당)" {
                            if let currentCount = Int(dislikeCountLabel.text ?? "0") {
                                
                                // 파이어베이스 [데이터 불러오기]
                                let docRef = self.db.collection("Menu2").document(Data.currentDateStringSpace)
                                
                                docRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        if let like = document.data()?[mealType2] as? String {
                                            dislikeCountLabel.text = like
                                            
                                            print("1")
                                        }
                                        
                                    }
                                    
                                    else {
                                        print("   2   ")
                                    }
                                    
                                }
                                
                                
                                // 파이어베이스에 like수를 올리기 (메뉴쪽 한 번 보기) 병합되게 설정 [데이터쓰기]
                                self.db.collection("Menu2").document(Data.currentDateStringSpace).setData([ mealType2: "\(currentCount - 1)" ], merge: true)
                                
                                print(current_date_string)
                                
                            }
                        }
                        
                        if Data.navTitle == "식단표 (예지학사_식당)" {
                            if let currentCount = Int(dislikeCountLabel.text ?? "0") {
                                
                                // 파이어베이스 [데이터 불러오기]
                                let docRef = self.db.collection("Menu3").document(Data.currentDateStringSpace)
                                
                                docRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        if let like = document.data()?[mealType2] as? String {
                                            dislikeCountLabel.text = like
                                        }
                                        
                                    }
                                    
                                    else {
                                        print("   2   ")
                                    }
                                    
                                }
                                
                                
                                // 파이어베이스에 like수를 올리기 (메뉴쪽 한 번 보기) 병합되게 설정 [데이터쓰기]
                                self.db.collection("Menu3").document(Data.currentDateStringSpace).setData([ mealType2: "\(currentCount - 1)" ], merge: true)
                                
                                
                                
                            }
                        }
                        
                        if Data.navTitle == "식단표 (65번가_도서관지하분식점)" {
                            if let currentCount = Int(dislikeCountLabel.text ?? "0") {
                                
                                // 파이어베이스 [데이터 불러오기]
                                let docRef = self.db.collection("Menu4").document(Data.currentDateStringSpace)
                                
                                docRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        if let like = document.data()?[mealType2] as? String {
                                            dislikeCountLabel.text = like
                                        }
                                        
                                    }
                                    
                                    else {
                                        print("   2   ")
                                    }
                                    
                                }
                                
                                
                                // 파이어베이스에 like수를 올리기 (메뉴쪽 한 번 보기) 병합되게 설정 [데이터쓰기]
                                self.db.collection("Menu4").document(Data.currentDateStringSpace).setData([ mealType2: "\(currentCount - 1)" ], merge: true)
                                
                                
                                
                            }
                        }
                        
                        
                        
                        
                        // 버튼 탭 히스토리에 저장
                        // 탭 히스토리 초기화
                        buttonTapHistory = [:]
                        UserDefaults.standard.set(buttonTapHistory, forKey: buttonTapHistoryKey)
                    }
                    
                    
                    
                    // 좋아요 카운트 증가
                    if let likeCountLabel = cell.contentView.viewWithTag(1000) as? UILabel {
                        
                        if Data.navTitle == "식단표 (학생회관_학생식당)" {
                            if let currentCount = Int(likeCountLabel.text ?? "0") {
                                
                                // 파이어베이스 [데이터 불러오기]
                                let docRef = self.db.collection("Menu").document(Data.currentDateStringSpace)
                                
                                docRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        if let like = document.data()?[mealType] as? String {
                                            likeCountLabel.text = like
                                            
                                        }
                                        
                                    }
                                    
                                    else {
                                        print("식단 메뉴가 등록되지 않았습니다.")
                                    }
                                    
                                }
                                
                                
                                // 파이어베이스에 like수를 올리기 (메뉴쪽 한 번 보기) 병합되게 설정 [데이터쓰기]
                                self.db.collection("Menu").document(Data.currentDateStringSpace).setData([ mealType: "\(currentCount + 1)" ], merge: true)
                                
                                
                                
                            }
                        }
                        
                        if Data.navTitle == "식단표 (학생회관_자율식당)" {
                            if let currentCount = Int(likeCountLabel.text ?? "0") {
                                
                                // 파이어베이스 [데이터 불러오기]
                                let docRef = self.db.collection("Menu2").document(Data.currentDateStringSpace)
                                
                                docRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        if let like = document.data()?[mealType] as? String {
                                            likeCountLabel.text = like
                                            
                                            print("1")
                                        }
                                        
                                    }
                                    
                                    else {
                                        print("   2   ")
                                    }
                                    
                                }
                                
                                
                                // 파이어베이스에 like수를 올리기 (메뉴쪽 한 번 보기) 병합되게 설정 [데이터쓰기]
                                self.db.collection("Menu2").document(Data.currentDateStringSpace).setData([ mealType: "\(currentCount + 1)" ], merge: true)
                                
                                
                                
                            }
                        }
                        
                        if Data.navTitle == "식단표 (예지학사_식당)" {
                            if let currentCount = Int(likeCountLabel.text ?? "0") {
                                
                                // 파이어베이스 [데이터 불러오기]
                                let docRef = self.db.collection("Menu3").document(Data.currentDateStringSpace)
                                
                                docRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        if let like = document.data()?[mealType] as? String {
                                            likeCountLabel.text = like
                                            
                                            print("1")
                                        }
                                        
                                    }
                                    
                                    else {
                                        print("   2   ")
                                    }
                                    
                                }
                                
                                
                                // 파이어베이스에 like수를 올리기 (메뉴쪽 한 번 보기) 병합되게 설정 [데이터쓰기]
                                self.db.collection("Menu3").document(Data.currentDateStringSpace).setData([ mealType: "\(currentCount + 1)" ], merge: true)
                                
                                
                                
                            }
                        }
                        
                        if Data.navTitle == "식단표 (65번가_도서관지하분식점)" {
                            if let currentCount = Int(likeCountLabel.text ?? "0") {
                                
                                // 파이어베이스 [데이터 불러오기]
                                let docRef = self.db.collection("Menu4").document(Data.currentDateStringSpace)
                                
                                docRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        if let like = document.data()?[mealType] as? String {
                                            likeCountLabel.text = like
                                            
                                            print("1")
                                        }
                                        
                                    }
                                    
                                    else {
                                        print("   2   ")
                                    }
                                    
                                }
                                
                                
                                // 파이어베이스에 like수를 올리기 (메뉴쪽 한 번 보기) 병합되게 설정 [데이터쓰기]
                                self.db.collection("Menu4").document(Data.currentDateStringSpace).setData([ mealType: "\(currentCount + 1)" ], merge: true)
                                
                                
                                
                            }
                        }
                        
                    }
                    
                    
                    
                    // 버튼 탭 히스토리에 저장 (dislike 초기화)
                    buttonTapHistory2 = [:]
                    UserDefaults.standard.set(buttonTapHistory2, forKey: buttonTapHistoryKey2)
                    //
                    
                    
                    // 버튼 탭 히스토리에 저장 (like 생성)
                    buttonTapHistory["likeButtonTapped"] = true
                    UserDefaults.standard.set(buttonTapHistory, forKey: buttonTapHistoryKey)
                    //
                    
                }
                
                
                //좋아요 1 증가
                else {
                    
                    
                    // 라벨을 가져오는게 아니라 데이터베이스의 데이터를 가져와서 증가시켜야할뜻
                    // -> 실시간 데이터베이스를 활용?
                    
                    
                    if let likeCountLabel = cell.contentView.viewWithTag(1000) as? UILabel {
                        
                        if Data.navTitle == "식단표 (학생회관_학생식당)" {
                            if let currentCount = Int(likeCountLabel.text ?? "0") {
                                
                                // 파이어베이스 [데이터 불러오기]
                                let docRef = self.db.collection("Menu").document(Data.currentDateStringSpace)
                                
                                
                                docRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        if let like = document.data()?[mealType] as? String {
                                            likeCountLabel.text = like
                                            
                                        }
                                        
                                    }
                                    
                                    else {
                                        print("식단 메뉴가 등록되지 않았습니다.")
                                    }
                                    
                                }
                                
                                
                                
                                //                                // 데이터 변경 사항을 수신하는 메서드 // 기기로 한 번 테스트
                                //                                docRef.addSnapshotListener { (document, error) in
                                //                                    guard let document = document else {
                                //                                        print("Error fetching document: \(error!)")
                                //                                        return
                                //                                    }
                                //
                                //                                    if document.exists {
                                //                                        if let like = document.data()?[mealType] as? String {
                                //                                            likeCountLabel.text = like
                                //                                        }
                                //                                    } else {
                                //                                        print("Document does not exist")
                                //                                    }
                                //                                }
                                //
                                //
                                
                                
                                
                                
                                // 파이어베이스에 like수를 올리기 (메뉴쪽 한 번 보기) 병합되게 설정 [데이터쓰기]
                                self.db.collection("Menu").document(Data.currentDateStringSpace).setData([ mealType: "\(currentCount + 1)" ], merge: true)
                                
                                
                                
                            }
                        }
                        
                        if Data.navTitle == "식단표 (학생회관_자율식당)" {
                            if let currentCount = Int(likeCountLabel.text ?? "0") {
                                
                                // 파이어베이스 [데이터 불러오기]
                                let docRef = self.db.collection("Menu2").document(Data.currentDateStringSpace)
                                
                                docRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        if let like = document.data()?[mealType] as? String {
                                            likeCountLabel.text = like
                                            
                                            print("1")
                                        }
                                        
                                    }
                                    
                                    else {
                                        print("   2   ")
                                    }
                                    
                                }
                                
                                
                                // 파이어베이스에 like수를 올리기 (메뉴쪽 한 번 보기) 병합되게 설정 [데이터쓰기]
                                self.db.collection("Menu2").document(Data.currentDateStringSpace).setData([ mealType: "\(currentCount + 1)" ], merge: true)
                                
                                
                                
                            }
                        }
                        
                        if Data.navTitle == "식단표 (예지학사_식당)" {
                            if let currentCount = Int(likeCountLabel.text ?? "0") {
                                
                                // 파이어베이스 [데이터 불러오기]
                                let docRef = self.db.collection("Menu3").document(Data.currentDateStringSpace)
                                
                                docRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        if let like = document.data()?[mealType] as? String {
                                            likeCountLabel.text = like
                                            
                                            print("1")
                                        }
                                        
                                    }
                                    
                                    else {
                                        print("   2   ")
                                    }
                                    
                                }
                                
                                
                                // 파이어베이스에 like수를 올리기 (메뉴쪽 한 번 보기) 병합되게 설정 [데이터쓰기]
                                self.db.collection("Menu3").document(Data.currentDateStringSpace).setData([ mealType: "\(currentCount + 1)" ], merge: true)
                                
                                
                                
                            }
                        }
                        
                        if Data.navTitle == "식단표 (65번가_도서관지하분식점)" {
                            if let currentCount = Int(likeCountLabel.text ?? "0") {
                                
                                // 파이어베이스 [데이터 불러오기]
                                let docRef = self.db.collection("Menu4").document(Data.currentDateStringSpace)
                                
                                docRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        if let like = document.data()?[mealType] as? String {
                                            likeCountLabel.text = like
                                            
                                            print("1")
                                        }
                                        
                                    }
                                    
                                    else {
                                        print("   2   ")
                                    }
                                    
                                }
                                
                                
                                // 파이어베이스에 like수를 올리기 (메뉴쪽 한 번 보기) 병합되게 설정 [데이터쓰기]
                                self.db.collection("Menu4").document(Data.currentDateStringSpace).setData([ mealType: "\(currentCount + 1)" ], merge: true)
                                
                                
                                
                            }
                        }
                        
                    }
                    
                    // 버튼 탭 히스토리에 저장
                    buttonTapHistory["likeButtonTapped"] = true
                    UserDefaults.standard.set(buttonTapHistory, forKey: buttonTapHistoryKey)
                }
            }
        }
    }
    
    
    
    @objc func dislikeButtonTapped(_ sender: UIButton) {
        
        // 버튼 탭 시 에니메이션 추가
        UIView.animate(withDuration: 0.2, animations: {
            // Scale the button to make it appear as if it's tapped
            sender.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { (_) in
            // After the animation completes, restore the original size
            UIView.animate(withDuration: 0.2) {
                sender.transform = .identity
            }
        }
        
        // 현재 날짜 데이터 포맷
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let current_date_string = formatter.string(from: Date())
        
        
        // Get the cell containing the button
        if let cell = sender.superview?.superview as? UITableViewCell,
           
            let indexPath = tableView.indexPath(for: cell) {
            
            
            let mealType2: String
            switch indexPath.section {
            case 0:
                mealType2 = "아침메뉴Like"
            case 1:
                mealType2 = "점심메뉴Like"
            case 2:
                mealType2 = "저녁메뉴Like"
            default:
                mealType2 = ""
            }
            
            let mealType: String
            switch indexPath.section {
            case 0:
                mealType = "아침메뉴DisLike"
            case 1:
                mealType = "점심메뉴DisLike"
            case 2:
                mealType = "저녁메뉴DisLike"
            default:
                mealType = ""
            }
            
            
            
            
            // 한 유저당 딱 좋아요를 한 번만 누를 수 있는 기능 (앱 삭제 후 실행시 까지는 해결못함)
            // UserDefaults에서 버튼 탭 히스토리를 가져옴 (이쪽에 대해서 한번 공식문서 봐보기)
            
            
            
            // forKey
            let buttonTapHistoryKey = "\(Data.navTitle)_\(mealType)_\(Data.currentDateStringSpace)"
            
            
            // forKey2 like
            let buttonTapHistoryKey2 = "\(Data.navTitle)_\(mealType2)_\(Data.currentDateStringSpace)"
            
            
            //if buttonTapHistory["likeButtonTapped"] == true {return}
            
            
            
            
            var buttonTapHistory = UserDefaults.standard.dictionary(forKey: buttonTapHistoryKey) ?? [:]
            
            
            var buttonTapHistory2 = UserDefaults.standard.dictionary(forKey: buttonTapHistoryKey2) ?? [:]
            
            
            
            
            // 이미 탭한 적이 있는지 확인 (disLike)
            if let tapped = buttonTapHistory["dislikeButtonTapped"] as? Bool, tapped {
                
                
                
                let alert = UIAlertController(title: "", message: "싫어요가 취소되셨습니다.", preferredStyle: .alert)
                
                
                present(alert, animated: true) {
                    // 문구가 1초뒤 사라지게 설정
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                           alert.dismiss(animated: true, completion: nil)
                       }
                }
                
                
                
                
                // 증가 시킨적이 있으면 싫어요 1 감소
                
                if let dislikeCountLabel = cell.contentView.viewWithTag(2000) as? UILabel {
                    
                    if Data.navTitle == "식단표 (학생회관_학생식당)" {
                        if let currentCount = Int(dislikeCountLabel.text ?? "0") {
                            
                            // 파이어베이스 [데이터 불러오기]
                            let docRef = self.db.collection("Menu").document(Data.currentDateStringSpace)
                            
                            docRef.getDocument { (document, error) in
                                if let document = document, document.exists {
                                    if let like = document.data()?[mealType] as? String {
                                        dislikeCountLabel.text = like
                                        
                                        
                                    }
                                    
                                }
                                
                                else {
                                    print("   2   ")
                                }
                                
                            }
                            
                            
                            // 파이어베이스에 like수를 올리기 (메뉴쪽 한 번 보기) 병합되게 설정 [데이터쓰기]
                            self.db.collection("Menu").document(Data.currentDateStringSpace).setData([ mealType: "\(currentCount - 1)" ], merge: true)
                            
                            print(current_date_string)
                            
                        }
                    }
                    
                    if Data.navTitle == "식단표 (학생회관_자율식당)" {
                        if let currentCount = Int(dislikeCountLabel.text ?? "0") {
                            
                            // 파이어베이스 [데이터 불러오기]
                            let docRef = self.db.collection("Menu2").document(Data.currentDateStringSpace)
                            
                            docRef.getDocument { (document, error) in
                                if let document = document, document.exists {
                                    if let like = document.data()?[mealType] as? String {
                                        dislikeCountLabel.text = like
                                        
                                        print("1")
                                    }
                                    
                                }
                                
                                else {
                                    print("   2   ")
                                }
                                
                            }
                            
                            
                            // 파이어베이스에 like수를 올리기 (메뉴쪽 한 번 보기) 병합되게 설정 [데이터쓰기]
                            self.db.collection("Menu2").document(Data.currentDateStringSpace).setData([ mealType: "\(currentCount - 1)" ], merge: true)
                            
                            print(current_date_string)
                            
                        }
                    }
                    
                    if Data.navTitle == "식단표 (예지학사_식당)" {
                        if let currentCount = Int(dislikeCountLabel.text ?? "0") {
                            
                            // 파이어베이스 [데이터 불러오기]
                            let docRef = self.db.collection("Menu3").document(Data.currentDateStringSpace)
                            
                            docRef.getDocument { (document, error) in
                                if let document = document, document.exists {
                                    if let like = document.data()?[mealType] as? String {
                                        dislikeCountLabel.text = like
                                    }
                                    
                                }
                                
                                else {
                                    print("   2   ")
                                }
                                
                            }
                            
                            
                            // 파이어베이스에 like수를 올리기 (메뉴쪽 한 번 보기) 병합되게 설정 [데이터쓰기]
                            self.db.collection("Menu3").document(Data.currentDateStringSpace).setData([ mealType: "\(currentCount - 1)" ], merge: true)
                            
                            
                            
                        }
                    }
                    
                    if Data.navTitle == "식단표 (65번가_도서관지하분식점)" {
                        if let currentCount = Int(dislikeCountLabel.text ?? "0") {
                            
                            // 파이어베이스 [데이터 불러오기]
                            let docRef = self.db.collection("Menu4").document(Data.currentDateStringSpace)
                            
                            docRef.getDocument { (document, error) in
                                if let document = document, document.exists {
                                    if let like = document.data()?[mealType] as? String {
                                        dislikeCountLabel.text = like
                                    }
                                    
                                }
                                
                                else {
                                    print("   2   ")
                                }
                                
                            }
                            
                            
                            // 파이어베이스에 like수를 올리기 (메뉴쪽 한 번 보기) 병합되게 설정 [데이터쓰기]
                            self.db.collection("Menu4").document(Data.currentDateStringSpace).setData([ mealType: "\(currentCount - 1)" ], merge: true)
                            
                            
                            
                        }
                    }
                    
                    
                    // 버튼 탭 히스토리에 저장
                    // 탭 히스토리 초기화
                    buttonTapHistory = [:]
                    UserDefaults.standard.set(buttonTapHistory, forKey: buttonTapHistoryKey)
                }
                
                
            }
            // 좋아요 탭 기록을 삭제하고 싫어요 탭 기록을 생성해야함.
            
            
            
            // 증가 시킨적이 없다면
            else {
                
                let alert = UIAlertController(title: "", message: "싫어요를 선택하셨습니다.", preferredStyle: .alert)
                
                
                present(alert, animated: true) {
                    // 문구가 1초뒤 사라지게 설정
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                           alert.dismiss(animated: true, completion: nil)
                       }
                }
                
                
                
                // (Like)를 이미 탭한 적이 있는지 확인
                if let likeTappedCheck = buttonTapHistory2["likeButtonTapped"] as? Bool, likeTappedCheck {
                    
                    
                    // 좋아요 카운트 감소
                    if let likeCountLabel = cell.contentView.viewWithTag(1000) as? UILabel {
                        
                        if Data.navTitle == "식단표 (학생회관_학생식당)" {
                            if let currentCount = Int(likeCountLabel.text ?? "0") {
                                
                                // 파이어베이스 [데이터 불러오기]
                                let docRef = self.db.collection("Menu").document(Data.currentDateStringSpace)
                                
                                docRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        if let like = document.data()?[mealType2] as? String {
                                            likeCountLabel.text = like
                                            
                                        }
                                        
                                    }
                                    
                                    else {
                                        print("식단 메뉴가 등록되지 않았습니다.")
                                    }
                                    
                                }
                                
                                
                                // 파이어베이스에 like수를 올리기 (메뉴쪽 한 번 보기) 병합되게 설정 [데이터쓰기]
                                self.db.collection("Menu").document(Data.currentDateStringSpace).setData([ mealType2: "\(currentCount - 1)" ], merge: true)
                                
                                
                                
                            }
                        }
                        
                        if Data.navTitle == "식단표 (학생회관_자율식당)" {
                            if let currentCount = Int(likeCountLabel.text ?? "0") {
                                
                                // 파이어베이스 [데이터 불러오기]
                                let docRef = self.db.collection("Menu2").document(Data.currentDateStringSpace)
                                
                                docRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        if let like = document.data()?[mealType2] as? String {
                                            likeCountLabel.text = like
                                            
                                            print("1")
                                        }
                                        
                                    }
                                    
                                    else {
                                        print("   2   ")
                                    }
                                    
                                }
                                
                                
                                // 파이어베이스에 like수를 올리기 (메뉴쪽 한 번 보기) 병합되게 설정 [데이터쓰기]
                                self.db.collection("Menu2").document(Data.currentDateStringSpace).setData([ mealType2: "\(currentCount - 1)" ], merge: true)
                                
                                
                                
                            }
                        }
                        
                        if Data.navTitle == "식단표 (예지학사_식당)" {
                            if let currentCount = Int(likeCountLabel.text ?? "0") {
                                
                                // 파이어베이스 [데이터 불러오기]
                                let docRef = self.db.collection("Menu3").document(Data.currentDateStringSpace)
                                
                                docRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        if let like = document.data()?[mealType2] as? String {
                                            likeCountLabel.text = like
                                            
                                            print("1")
                                        }
                                        
                                    }
                                    
                                    else {
                                        print("   2   ")
                                    }
                                    
                                }
                                
                                
                                // 파이어베이스에 like수를 올리기 (메뉴쪽 한 번 보기) 병합되게 설정 [데이터쓰기]
                                self.db.collection("Menu3").document(Data.currentDateStringSpace).setData([ mealType2: "\(currentCount - 1)" ], merge: true)
                                
                                
                                
                                
                                
                            }
                        }
                        
                        if Data.navTitle == "식단표 (65번가_도서관지하분식점)" {
                            if let currentCount = Int(likeCountLabel.text ?? "0") {
                                
                                // 파이어베이스 [데이터 불러오기]
                                let docRef = self.db.collection("Menu4").document(Data.currentDateStringSpace)
                                
                                docRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        if let like = document.data()?[mealType2] as? String {
                                            likeCountLabel.text = like
                                            
                                            print("1")
                                        }
                                        
                                    }
                                    
                                    else {
                                        print("   2   ")
                                    }
                                    
                                }
                                
                                
                                // 파이어베이스에 like수를 올리기 (메뉴쪽 한 번 보기) 병합되게 설정 [데이터쓰기]
                                self.db.collection("Menu4").document(Data.currentDateStringSpace).setData([ mealType2: "\(currentCount - 1)" ], merge: true)
                                
                                
                                
                            }
                        }
                        
                    }
                    
                    // 싫어요 카운트 증가
                    if let dislikeCountLabel = cell.contentView.viewWithTag(2000) as? UILabel {
                        
                        if Data.navTitle == "식단표 (학생회관_학생식당)" {
                            if let currentCount = Int(dislikeCountLabel.text ?? "0") {
                                
                                // 파이어베이스 [데이터 불러오기]
                                let docRef = self.db.collection("Menu").document(Data.currentDateStringSpace)
                                
                                docRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        if let like = document.data()?[mealType] as? String {
                                            dislikeCountLabel.text = like
                                            
                                            
                                        }
                                        
                                    }
                                    
                                    else {
                                        print("   2   ")
                                    }
                                    
                                }
                                
                                
                                // 파이어베이스에 like수를 올리기 (메뉴쪽 한 번 보기) 병합되게 설정 [데이터쓰기]
                                self.db.collection("Menu").document(Data.currentDateStringSpace).setData([ mealType: "\(currentCount + 1)" ], merge: true)
                                
                                print(current_date_string)
                                
                            }
                        }
                        
                        if Data.navTitle == "식단표 (학생회관_자율식당)" {
                            if let currentCount = Int(dislikeCountLabel.text ?? "0") {
                                
                                // 파이어베이스 [데이터 불러오기]
                                let docRef = self.db.collection("Menu2").document(Data.currentDateStringSpace)
                                
                                docRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        if let like = document.data()?[mealType] as? String {
                                            dislikeCountLabel.text = like
                                            
                                            print("1")
                                        }
                                        
                                    }
                                    
                                    else {
                                        print("   2   ")
                                    }
                                    
                                }
                                
                                
                                // 파이어베이스에 like수를 올리기 (메뉴쪽 한 번 보기) 병합되게 설정 [데이터쓰기]
                                self.db.collection("Menu2").document(Data.currentDateStringSpace).setData([ mealType: "\(currentCount + 1)" ], merge: true)
                                
                                print(current_date_string)
                                
                            }
                        }
                        
                        if Data.navTitle == "식단표 (예지학사_식당)" {
                            if let currentCount = Int(dislikeCountLabel.text ?? "0") {
                                
                                // 파이어베이스 [데이터 불러오기]
                                let docRef = self.db.collection("Menu3").document(Data.currentDateStringSpace)
                                
                                docRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        if let like = document.data()?[mealType] as? String {
                                            dislikeCountLabel.text = like
                                            
                                            
                                        }
                                        
                                    }
                                    
                                    else {
                                        print("   2   ")
                                    }
                                    
                                }
                                
                                
                                // 파이어베이스에 like수를 올리기 (메뉴쪽 한 번 보기) 병합되게 설정 [데이터쓰기]
                                self.db.collection("Menu3").document(Data.currentDateStringSpace).setData([ mealType: "\(currentCount + 1)" ], merge: true)
                                
                                print(current_date_string)
                                
                            }
                        }
                        
                        if Data.navTitle == "식단표 (65번가_도서관지하분식점)" {
                            if let currentCount = Int(dislikeCountLabel.text ?? "0") {
                                
                                // 파이어베이스 [데이터 불러오기]
                                let docRef = self.db.collection("Menu4").document(Data.currentDateStringSpace)
                                
                                docRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        if let like = document.data()?[mealType] as? String {
                                            dislikeCountLabel.text = like
                                            
                                            
                                        }
                                        
                                    }
                                    
                                    else {
                                        print("   2   ")
                                    }
                                    
                                }
                                
                                
                                // 파이어베이스에 like수를 올리기 (메뉴쪽 한 번 보기) 병합되게 설정 [데이터쓰기]
                                self.db.collection("Menu4").document(Data.currentDateStringSpace).setData([ mealType: "\(currentCount + 1)" ], merge: true)
                            }
                        }
                        
                    }
                    
                    
                    
                    // 버튼 탭 히스토리에 저장 (like 초기화)
                    buttonTapHistory2 = [:]
                    UserDefaults.standard.set(buttonTapHistory2, forKey: buttonTapHistoryKey2)
                    //
                    
                    
                    // 버튼 탭 히스토리에 저장 (dislike 생성)
                    buttonTapHistory["dislikeButtonTapped"] = true
                    UserDefaults.standard.set(buttonTapHistory, forKey: buttonTapHistoryKey)
                    //
                    
                }
                
                
                // 싫어요 1 증가
                else {
                    if let dislikeCountLabel = cell.contentView.viewWithTag(2000) as? UILabel {
                        
                        if Data.navTitle == "식단표 (학생회관_학생식당)" {
                            if let currentCount = Int(dislikeCountLabel.text ?? "0") {
                                
                                // 파이어베이스 [데이터 불러오기]
                                let docRef = self.db.collection("Menu").document(Data.currentDateStringSpace)
                                
                                docRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        if let like = document.data()?[mealType] as? String {
                                            dislikeCountLabel.text = like
                                        }
                                    }
                                    else {
                                        print("   2   ")
                                    }
                                    
                                }
                                
                                
                                //                                // 데이터 변경 사항을 수신하는 메서드 // 기기로 한 번 테스트
                                //                                docRef.addSnapshotListener { (document, error) in
                                //                                    guard let document = document else {
                                //                                        print("Error fetching document: \(error!)")
                                //                                        return
                                //                                    }
                                //
                                //                                    if document.exists {
                                //                                        if let like = document.data()?[mealType] as? String {
                                //                                            // 데이터베이스의 값
                                //
                                //                                            dislikeCountLabel.text = like
                                //
                                //                                        }
                                //                                    } else {
                                //                                        print("Document does not exist")
                                //                                    }
                                //                                }
                                
                                
                                
                                // 파이어베이스에 like수를 올리기 (메뉴쪽 한 번 보기) 병합되게 설정 [데이터쓰기]
                                self.db.collection("Menu").document(Data.currentDateStringSpace).setData([ mealType: "\(currentCount + 1)" ], merge: true)
                                
                                
                                
                            }
                        }
                        
                        if Data.navTitle == "식단표 (학생회관_자율식당)" {
                            if let currentCount = Int(dislikeCountLabel.text ?? "0") {
                                
                                // 파이어베이스 [데이터 불러오기]
                                let docRef = self.db.collection("Menu2").document(Data.currentDateStringSpace)
                                
                                docRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        if let like = document.data()?[mealType] as? String {
                                            dislikeCountLabel.text = like
                                            
                                            print("1")
                                        }
                                        
                                    }
                                    
                                    else {
                                        print("   2   ")
                                    }
                                    
                                }
                                
                                
                                // 파이어베이스에 like수를 올리기 (메뉴쪽 한 번 보기) 병합되게 설정 [데이터쓰기]
                                self.db.collection("Menu2").document(Data.currentDateStringSpace).setData([ mealType: "\(currentCount + 1)" ], merge: true)
                                
                                print(current_date_string)
                                
                            }
                        }
                        
                        if Data.navTitle == "식단표 (예지학사_식당)" {
                            if let currentCount = Int(dislikeCountLabel.text ?? "0") {
                                
                                // 파이어베이스 [데이터 불러오기]
                                let docRef = self.db.collection("Menu3").document(Data.currentDateStringSpace)
                                
                                docRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        if let like = document.data()?[mealType] as? String {
                                            dislikeCountLabel.text = like
                                            
                                            
                                        }
                                        
                                    }
                                    
                                    else {
                                        print("   2   ")
                                    }
                                    
                                }
                                
                                
                                // 파이어베이스에 like수를 올리기 (메뉴쪽 한 번 보기) 병합되게 설정 [데이터쓰기]
                                self.db.collection("Menu3").document(Data.currentDateStringSpace).setData([ mealType: "\(currentCount + 1)" ], merge: true)
                                
                                print(current_date_string)
                                
                            }
                        }
                        
                        if Data.navTitle == "식단표 (65번가_도서관지하분식점)" {
                            if let currentCount = Int(dislikeCountLabel.text ?? "0") {
                                
                                // 파이어베이스 [데이터 불러오기]
                                let docRef = self.db.collection("Menu4").document(Data.currentDateStringSpace)
                                
                                docRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        if let like = document.data()?[mealType] as? String {
                                            dislikeCountLabel.text = like
                                            
                                            
                                        }
                                        
                                    }
                                    
                                    else {
                                        print("   2   ")
                                    }
                                    
                                }
                                
                                
                                // 파이어베이스에 like수를 올리기 (메뉴쪽 한 번 보기) 병합되게 설정 [데이터쓰기]
                                self.db.collection("Menu4").document(Data.currentDateStringSpace).setData([ mealType: "\(currentCount + 1)" ], merge: true)
                            }
                        }
                        
                    }
                    
                    // 버튼 탭 히스토리에 저장 (dislike 생성)
                    buttonTapHistory["dislikeButtonTapped"] = true
                    UserDefaults.standard.set(buttonTapHistory, forKey: buttonTapHistoryKey)
                    //
                    
                }
            }
            
            
        }
    }
    
    
    
    
    
    
    
    
    // 섹션
    func numberOfSections(in tableView: UITableView) -> Int {
        return header.count
    }
    
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return header[section]
    }
    
    // 섹션 글자색 변경
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
           // 섹션 헤더의 뷰가 표시될 때 호출되는 함수
           guard let header = view as? UITableViewHeaderFooterView else { return }
           
           // 섹션 헤더의 글자색 설정
           header.textLabel?.textColor = UIColor(hexCode: "#c8d6e5") // 변경하고자 하는 색상으로 설정
       }
    
    
    // 로우 높이 (높이 자동 조절)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // 열 선택시 아무일도 일어나지 않게 설정
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.selectionStyle = .none
    }
    
    
    
    
    
    
    
}





// 캘린더 주말 요일 UI 설정
extension ViewController: FSCalendarDelegateAppearance {
    
    // 토요일 파랑, 일요일 빨강으로 만들기
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        let day = Calendar.current.component(.weekday, from: date) - 1
        
        if Calendar.current.shortWeekdaySymbols[day] == "Sun" || Calendar.current.shortWeekdaySymbols[day] == "일" {
            return UIColor(hexCode: "#d63031")
        } else if Calendar.current.shortWeekdaySymbols[day] == "Sat" || Calendar.current.shortWeekdaySymbols[day] == "토" {
            return UIColor(hexCode: "#0984e3")
        } else if Calendar.current.shortWeekdaySymbols[day] == "Mon" ||
                    Calendar.current.shortWeekdaySymbols[day] == "월" {
            return UIColor(hexCode: "#c8d6e5")
        } else if Calendar.current.shortWeekdaySymbols[day] == "Tue" ||
                    Calendar.current.shortWeekdaySymbols[day] == "화" {
            return UIColor(hexCode: "#c8d6e5")
        } else if Calendar.current.shortWeekdaySymbols[day] == "Wed" ||
                    Calendar.current.shortWeekdaySymbols[day] == "수" {
            return UIColor(hexCode: "#c8d6e5")
        } else if Calendar.current.shortWeekdaySymbols[day] == "Thu" ||
                    Calendar.current.shortWeekdaySymbols[day] == "목" {
            return UIColor(hexCode: "#c8d6e5")
        } else if Calendar.current.shortWeekdaySymbols[day] == "Fri" ||
                    Calendar.current.shortWeekdaySymbols[day] == "금" {
            return UIColor(hexCode: "#c8d6e5")
        }
        
        
        else {
            return .label
        }
    }
}

// 16진수 컬러 사용 확장
extension UIColor {
    
    convenience init(hexCode: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hexCode.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "Invalid hex code used.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
}

// UIImage 색상 변경 확장
extension UIImage {
    func imageWithColor(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color.setFill()

        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(CGBlendMode.normal)

        let rect = CGRect(origin: .zero, size: CGSize(width: self.size.width, height: self.size.height))
        context?.clip(to: rect, mask: self.cgImage!)
        context?.fill(rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}

