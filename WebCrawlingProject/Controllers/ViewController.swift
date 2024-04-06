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
 
 
 1.0.5 ->
 
 [1.0.5 (1)]
 -> iPad Air 모델에서 위젯 UI가 깨지는 버그 현상 -> 해결 완료 (17.0 이하 버전을 따로 설정하지 않아서 그럼(ZStack으로 해결) [1.0.5 (1)]
 
 
 [1.0.5 (2,3)]
 -> 위젯 글자 크기 키우기 (Bold 채로 변경 완료)
 
 
 -> widget날짜 포맷팅을 년도가 안나오게 변경 -> 완료 (요일까지 나오게 변경)
 
 
 -> SamllWidget 시간을 변경 -> 완료 (00시 ~ 10 || 10 ~ 15 || 15 ~ 00)
 
 
 -> 식단이 없는 날짜는 위젯이 안나오는 버그 -> 파이어베이스에 기본값을 넣어 임시방편으로 해결
 
 
 [1.0.5 (4)]
 
 -> 알림 버그 수정 (앱을 작동하지 않으면 알림에서 전 기록의 알림이 발송됨) -> 00시에 확인해보기x -> 임시 FCM을 사용하여 이용
 
 
 
 [1.0.6 (1)]
 -> 잠금 화면 위젯 추가 (완료)
 
 -> smallWidget 설명 문구 수정 (완료)
 
 
 
 [1.0.6 (2)]
 -> 위젯 UI/UX 디자인 수정 (완료)-> 줄 바꿈이 제대로 안되면 조금깨짐
 
 -> 잠금화면 small 위젯 설명 수정(완료)
 
 [1.0.6 (3)]
 -> 위젯 UI/UX 디자인 수정 (재수정 완료)-> 줄 바꿈이 제대로 안되면 조금깨짐
 
 
 
 [1.0.7 (1)
 -> 파이어베이스 getDocument 중복을 제거
 
 
 [1.0.7 (2)
 -> 중복되는 코드를 switch 문으로 정리
 
 
 */




/*
 <예정>
 
 
 
 -> 셀리니움을 통해서 자동화 도구 만들기
 
 
 
 
 
 */


/* 노션필기
 //                CalWidgetEntryView(entry: entry)
 //                    //.padding()
 //                    //.frame(maxWidth: .infinity, maxHeight: .infinity)    // << here !! 전체색 변경
 //                   // .background(Color(hex: 0x222f3e))
 //                    .padding() // Add padding to the content
 //                    .background(Color(hex: 0x222f3e)) // Set background color
 //
 //
 //            }
 */


//

import UIKit
import FSCalendar
import FirebaseCore
import FirebaseFirestore




class ViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, UITextFieldDelegate {
    
    
    
    
    // 파이어베이스
    let db = Firestore.firestore()
    
    
    // mealData
    let meal = MealType()
    
    
    
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
        
        
        self.navigationItem.title = ""
        
        
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
        
        view.backgroundColor = UIColor(hexCode: "#222f3e") // backgroundColor
        
        
        view.addSubview(calendar)
        view.addSubview(self.tableView)
        
        tableView.backgroundColor = UIColor(hexCode: "#222f3e") // tableColor
        
        
        
        calendar.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        
        
        // 캘린더 UI
        NSLayoutConstraint.activate([
            calendar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            calendar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            calendar.topAnchor.constraint(equalTo: view.topAnchor, constant: 120), // 조정된 위치
            calendar.heightAnchor.constraint(equalToConstant: 200) // 조정된 높이
        ])
        
        // 테이블 UI
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
        
        Data.currentDateStringSpace = dateFormatter.string(from: date)
        
        
        switch Data.navTitle {
        case meal.mealType[0]:
            getFirebaseData(menu: "Menu", date: dateFormatter.string(from: date))
        case meal.mealType[1]:
            getFirebaseData(menu: "Menu2", date: dateFormatter.string(from: date))
        case meal.mealType[2]:
            getFirebaseData(menu: "Menu3", date: dateFormatter.string(from: date))
        case meal.mealType[3]:
            getFirebaseData(menu: "Menu4", date: dateFormatter.string(from: date))
        default:
            break
        }
        
        self.tableView.reloadData()
        
    }
    
    
    private func dateNow() {
            
        // 현재 날짜 데이터 포맷
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let currentDateString = formatter.string(from: Date())
        
        
        switch Data.navTitle {
        case meal.mealType[0]:
            getAnimationgetFirebaseData(menu: "Menu", date: currentDateString)
        case meal.mealType[1]:
            getAnimationgetFirebaseData(menu: "Menu2", date: currentDateString)
        case meal.mealType[2]:
            getAnimationgetFirebaseData(menu: "Menu3", date: currentDateString)
        case meal.mealType[3]:
            getAnimationgetFirebaseData(menu: "Menu4", date: currentDateString)
        default:
            break
        }
        
        // 이곳이 데이터 로딩이 끝내는 함수
        self.tableView.reloadData()
        
        
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
    
    
    
    // ⭐️에니메이션과 일반으로 나눈것은 처음 데이터를 불러오는 시간은 오래 걸리지만 캘린더를 선택해서 데이터를 불러오는건 에니메이션 시간이 아까움.
    
    
    private func getFirebaseData(menu: String, date: String) {
        
        let docRef = db.collection(menu).document(date)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let breakMenu = document.data()?["아침메뉴"] as? String {
                    if let lunchMenu = document.data()?["점심메뉴"] as? String {
                        if let dinnerMenu = document.data()?["저녁메뉴"] as? String {
                            let breakMenu = breakMenu.replacingOccurrences(of: "\\n", with: "\n")
                            let lunchMenu = lunchMenu.replacingOccurrences(of: "\\n", with: "\n")
                            let dinnerMenu = dinnerMenu.replacingOccurrences(of: "\\n", with: "\n")
                            
                            
                            
                            self.data = [[breakMenu],
                                         [lunchMenu],
                                         [dinnerMenu]]
                            
                            self.tableView.reloadData()
                            
                            
                            
                            
                        }
                    }
                }
            } else {
                self.data = [["아직 식단이 등록되지 않았습니다."],
                             ["아직 식단이 등록되지 않았습니다."],
                             ["아직 식단이 등록되지 않았습니다."]]
                
                self.tableView.reloadData()
            }
        }
    }
    
    private func getAnimationgetFirebaseData(menu: String, date: String) {
        
        let docRef = db.collection(menu).document(date)
        
        let loadingView = UIView(frame: view.bounds)
        let activityIndicator = UIActivityIndicatorView(style: .large)
        
        
        loadingView.backgroundColor = UIColor.lightGray
        activityIndicator.center = loadingView.center
        
        
        loadingView.addSubview(activityIndicator)
        view.addSubview(loadingView)
        activityIndicator.startAnimating()
        
    
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let breakMenu = document.data()?["아침메뉴"] as? String {
                    if let lunchMenu = document.data()?["점심메뉴"] as? String {
                        if let dinnerMenu = document.data()?["저녁메뉴"] as? String {
                            let breakMenu = breakMenu.replacingOccurrences(of: "\\n", with: "\n")
                            let lunchMenu = lunchMenu.replacingOccurrences(of: "\\n", with: "\n")
                            let dinnerMenu = dinnerMenu.replacingOccurrences(of: "\\n", with: "\n")
                            
                            
                            
                            self.data = [[breakMenu],
                                         [lunchMenu],
                                         [dinnerMenu]]
                            
                            activityIndicator.stopAnimating()
                            loadingView.removeFromSuperview()
                            
                            self.tableView.reloadData()
                            
                            
                            
                            
                        }
                    }
                }
            } else {
                self.data = [["아직 식단이 등록되지 않았습니다."],
                             ["아직 식단이 등록되지 않았습니다."],
                             ["아직 식단이 등록되지 않았습니다."]]
                
                activityIndicator.stopAnimating()
                loadingView.removeFromSuperview()
                self.tableView.reloadData()
            }
        }
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
        
        let likeCountLabel = UILabel()
        
        let dislikeCountLabel = UILabel()
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: .none)
        
        
        cell.backgroundColor = UIColor(hexCode: "#576574") // cellColor
        cell.textLabel?.numberOfLines = 0 // 줄바꿈 설정
        cell.textLabel?.textColor = UIColor(hexCode: "#c8d6e5") // tintColor
        cell.textLabel?.text = data[indexPath.section][indexPath.row]
        
        
        
        // 파이어베이스 [데이터 불러오기] (임시)
        let mealType: String
        let dismealType: String
        
        
        
        switch indexPath.section {
        case 0:
            mealType = "아침메뉴Like"
            dismealType = "아침메뉴DisLike"
        case 1:
            mealType = "점심메뉴Like"
            dismealType = "점심메뉴DisLike"
        case 2:
            mealType = "저녁메뉴Like"
            dismealType = "저녁메뉴DisLike"
        default:
            mealType = ""
            dismealType = ""
        }
        
        
        
        switch Data.navTitle {
        case meal.mealType[0]:
            getFirebaseDataSnapshotListener(menu: "Menu")
        case meal.mealType[1]:
            getFirebaseDataSnapshotListener(menu: "Menu2")
        case meal.mealType[2]:
            getFirebaseDataSnapshotListener(menu: "Menu3")
        case meal.mealType[3]:
            getFirebaseDataSnapshotListener(menu: "Menu4")
        default:
            break
        }
        
        
        
        // 파이어베이스 [데이터 불러오기]
        func getFirebaseDataSnapshotListener(menu: String) {
            let docRef = db.collection(menu).document(Data.currentDateStringSpace)
            
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
                    if let disLike = document.data()?[dismealType] as? String {
                        dislikeCountLabel.text = disLike
                        dislikeCountLabel.textColor = UIColor(hexCode: "#0abde3")
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
        
        
        // Add buttons to cell
        cell.contentView.addSubview(likeButton)
        cell.contentView.addSubview(dislikeButton)
        
        
        
        
        // Layout constraints for labels
        likeCountLabel.translatesAutoresizingMaskIntoConstraints = false
        dislikeCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        // Layout constraints for buttons
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        dislikeButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        
        
        NSLayoutConstraint.activate([
            dislikeButton.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -20),
            dislikeButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            
            likeButton.trailingAnchor.constraint(equalTo: dislikeButton.leadingAnchor, constant: -10),
            likeButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            
            
            
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
        
        // Get the cell containing the button
        if let cell = sender.superview?.superview as? UITableViewCell,
           
            let indexPath = tableView.indexPath(for: cell) {
            
            let mealType: String
            let mealType2: String
            
            
            switch indexPath.section {
            case 0:
                mealType = "아침메뉴Like"
                mealType2 = "아침메뉴DisLike"
            case 1:
                mealType = "점심메뉴Like"
                mealType2 = "점심메뉴DisLike"
            case 2:
                mealType = "저녁메뉴Like"
                mealType2 = "저녁메뉴DisLike"
            default:
                mealType = ""
                mealType2 = ""
            }
            
            
            
            // 한 유저당 딱 좋아요를 한 번만 누를 수 있는 기능 (앱 삭제 후 실행시 까지는 해결못함)
            // UserDefaults에서 버튼 탭 히스토리를 가져옴 (이쪽에 대해서 한번 공식문서 봐보기)
            
            // forKey
            var buttonTapHistoryKey = "\(Data.navTitle)_\(mealType)_\(Data.currentDateStringSpace)"
            var buttonTapHistoryKey2 = "\(Data.navTitle)_\(mealType2)_\(Data.currentDateStringSpace)"
            
            
            
            
            
            var buttonTapHistory = UserDefaults.standard.dictionary(forKey: buttonTapHistoryKey) ?? [:]
            var buttonTapHistory2 = UserDefaults.standard.dictionary(forKey: buttonTapHistoryKey2) ?? [:]
            
            
            
            // LikeCount 1 감소
            func minusLikeCount(menu: String) {
                // 카운트 감소
                if let likeCountLabel = cell.contentView.viewWithTag(1000) as? UILabel {
                    
                    
                    
                    if let currentCount = Int(likeCountLabel.text ?? "0") {
                        
                        // 파이어베이스 [데이터 불러오기]
                        let docRef = self.db.collection(menu).document(Data.currentDateStringSpace)
                        
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
                        self.db.collection(menu).document(Data.currentDateStringSpace).setData([ mealType: "\(currentCount - 1)" ], merge: true)
                        
                        
                        
                    }
                    
                    
                }
            }
            
            
            // DisLikeCount 1 감소
            func minusDisLikeCount(menu: String) {
                // 싫어요 카운트 감소
                if let dislikeCountLabel = cell.contentView.viewWithTag(2000) as? UILabel {
                    if let currentCount = Int(dislikeCountLabel.text ?? "0") {
                        
                        // 파이어베이스 [데이터 불러오기]
                        let docRef = self.db.collection(menu).document(Data.currentDateStringSpace)
                        
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
                        self.db.collection(menu).document(Data.currentDateStringSpace).setData([ mealType2: "\(currentCount - 1)" ], merge: true)
                        
                    }
                }
            }
            
            
            // LikeCount 1 증가
            func plusLikeCount(menu: String) {
                if let likeCountLabel = cell.contentView.viewWithTag(1000) as? UILabel {
                    if let currentCount = Int(likeCountLabel.text ?? "0") {
                        
                        // 파이어베이스 [데이터 불러오기]
                        let docRef = self.db.collection(menu).document(Data.currentDateStringSpace)
                        
                        
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
                        self.db.collection(menu).document(Data.currentDateStringSpace).setData([ mealType: "\(currentCount + 1)" ], merge: true)
                    }
                }
            }
            
            
            
            
            // 이미 탭한 적이 있는지 확인
            // 탭 한적이 있으면 1 감소, 없으면 1 증가
            if let tapped = buttonTapHistory["likeButtonTapped"] as? Bool, tapped {
                
                // 알림창
                let alert = UIAlertController(title: "", message: "좋아요가 취소되셨습니다.", preferredStyle: .alert)
                present(alert, animated: true) {
                    // 문구가 1초뒤 사라지게 설정
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        alert.dismiss(animated: true, completion: nil)
                    }
                }
                
                switch Data.navTitle {
                case meal.mealType[0]:
                    minusLikeCount(menu: "Menu")
                case meal.mealType[1]:
                    minusLikeCount(menu: "Menu2")
                case meal.mealType[2]:
                    minusLikeCount(menu: "Menu3")
                case meal.mealType[3]:
                    minusLikeCount(menu: "Menu4")
                default:
                    break
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
                    
                    switch Data.navTitle {
                    case meal.mealType[0]:
                        minusDisLikeCount(menu: "Menu")
                        plusLikeCount(menu: "Menu")
                    case meal.mealType[1]:
                        minusDisLikeCount(menu: "Menu2")
                        plusLikeCount(menu: "Menu2")
                    case meal.mealType[2]:
                        minusDisLikeCount(menu: "Menu3")
                        plusLikeCount(menu: "Menu3")
                    case meal.mealType[3]:
                        minusDisLikeCount(menu: "Menu4")
                        plusLikeCount(menu: "Menu4")
                    default:
                        break
                    }
                    
                    
                    // 버튼 탭 히스토리에 저장 (dislike 초기화)
                    buttonTapHistory2 = [:]
                    UserDefaults.standard.set(buttonTapHistory2, forKey: buttonTapHistoryKey2)
                    
                    // 버튼 탭 히스토리에 저장 (like 생성)
                    buttonTapHistory["likeButtonTapped"] = true
                    UserDefaults.standard.set(buttonTapHistory, forKey: buttonTapHistoryKey)
                    
                }
                
                //좋아요 1 증가
                else {
                    
                    switch Data.navTitle {
                    case meal.mealType[0]:
                        plusLikeCount(menu: "Menu")
                    case meal.mealType[1]:
                        plusLikeCount(menu: "Menu2")
                    case meal.mealType[2]:
                        plusLikeCount(menu: "Menu3")
                    case meal.mealType[3]:
                        plusLikeCount(menu: "Menu4")
                    default:
                        break
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
        
        
        // Get the cell containing the button
        if let cell = sender.superview?.superview as? UITableViewCell,
           
            let indexPath = tableView.indexPath(for: cell) {
            
            let mealType: String
            let mealType2: String
            
            
            switch indexPath.section {
            case 0:
                mealType = "아침메뉴DisLike"
                mealType2 = "아침메뉴Like"
            case 1:
                mealType = "점심메뉴DisLike"
                mealType2 = "점심메뉴Like"
            case 2:
                mealType = "저녁메뉴DisLike"
                mealType2 = "저녁메뉴Like"
            default:
                mealType = ""
                mealType2 = ""
            }
            
            
            
            // 한 유저당 딱 좋아요를 한 번만 누를 수 있는 기능 (앱 삭제 후 실행시 까지는 해결못함)
            // UserDefaults에서 버튼 탭 히스토리를 가져옴 (이쪽에 대해서 한번 공식문서 봐보기)
            // forKey
            let buttonTapHistoryKey = "\(Data.navTitle)_\(mealType)_\(Data.currentDateStringSpace)"
            let buttonTapHistoryKey2 = "\(Data.navTitle)_\(mealType2)_\(Data.currentDateStringSpace)"
            
            
            
            
            var buttonTapHistory = UserDefaults.standard.dictionary(forKey: buttonTapHistoryKey) ?? [:]
            var buttonTapHistory2 = UserDefaults.standard.dictionary(forKey: buttonTapHistoryKey2) ?? [:]
            
            
            
            func minusDisLikeCount(menu: String) {
                
                // 증가 시킨적이 있으면 싫어요 1 감소
                if let dislikeCountLabel = cell.contentView.viewWithTag(2000) as? UILabel {
                    
                    
                    if let currentCount = Int(dislikeCountLabel.text ?? "0") {
                        
                        // 파이어베이스 [데이터 불러오기]
                        let docRef = self.db.collection(menu).document(Data.currentDateStringSpace)
                        
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
                        self.db.collection(menu).document(Data.currentDateStringSpace).setData([ mealType: "\(currentCount - 1)" ], merge: true)
                    }
                    
                }
            }
            
            
            func minusLikeCount(menu: String) {
                // 좋아요 카운트 감소
                if let likeCountLabel = cell.contentView.viewWithTag(1000) as? UILabel {
                    
                    if let currentCount = Int(likeCountLabel.text ?? "0") {
                        
                        // 파이어베이스 [데이터 불러오기]
                        let docRef = self.db.collection(menu).document(Data.currentDateStringSpace)
                        
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
                        self.db.collection(menu).document(Data.currentDateStringSpace).setData([ mealType2: "\(currentCount - 1)" ], merge: true)
                    }
                }
            }
            
            
            func plusDisLikeCount(menu: String) {
                // 싫어요 카운트 증가
                if let dislikeCountLabel = cell.contentView.viewWithTag(2000) as? UILabel {
                    if let currentCount = Int(dislikeCountLabel.text ?? "0") {
                        
                        // 파이어베이스 [데이터 불러오기]
                        let docRef = self.db.collection(menu).document(Data.currentDateStringSpace)
                        
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
                        self.db.collection(menu).document(Data.currentDateStringSpace).setData([ mealType: "\(currentCount + 1)" ], merge: true)
                    }
                }
            }
            
            
            // 이미 탭한 적이 있는지 확인 (disLike)
            if let tapped = buttonTapHistory["dislikeButtonTapped"] as? Bool, tapped {
                
                let alert = UIAlertController(title: "", message: "싫어요가 취소되셨습니다.", preferredStyle: .alert)
                present(alert, animated: true) {
                    // 문구가 1초뒤 사라지게 설정
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        alert.dismiss(animated: true, completion: nil)
                    }
                }
                
                switch Data.navTitle {
                case meal.mealType[0]:
                    minusDisLikeCount(menu: "Menu")
                case meal.mealType[1]:
                    minusDisLikeCount(menu: "Menu2")
                case meal.mealType[2]:
                    minusDisLikeCount(menu: "Menu3")
                case meal.mealType[3]:
                    minusDisLikeCount(menu: "Menu4")
                default:
                    break
                }
                
                // 버튼 탭 히스토리에 저장
                // 탭 히스토리 초기화
                buttonTapHistory = [:]
                UserDefaults.standard.set(buttonTapHistory, forKey: buttonTapHistoryKey)
                
            }
            
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
                    
                    switch Data.navTitle {
                    case meal.mealType[0]:
                        minusLikeCount(menu: "Menu")
                        plusDisLikeCount(menu: "Menu")
                    case meal.mealType[1]:
                        minusLikeCount(menu: "Menu2")
                        plusDisLikeCount(menu: "Menu2")
                    case meal.mealType[2]:
                        minusLikeCount(menu: "Menu3")
                        plusDisLikeCount(menu: "Menu3")
                    case meal.mealType[3]:
                        minusLikeCount(menu: "Menu4")
                        plusDisLikeCount(menu: "Menu4")
                    default:
                        break
                    }
                    
                    
                    // 버튼 탭 히스토리에 저장 (like 초기화)
                    buttonTapHistory2 = [:]
                    UserDefaults.standard.set(buttonTapHistory2, forKey: buttonTapHistoryKey2)
                    
                    
                    
                    // 버튼 탭 히스토리에 저장 (dislike 생성)
                    buttonTapHistory["dislikeButtonTapped"] = true
                    UserDefaults.standard.set(buttonTapHistory, forKey: buttonTapHistoryKey)
                    
                    
                }
                
                
                // 싫어요 1 증가
                else {
                    
                    
                    switch Data.navTitle {
                    case meal.mealType[0]:
                        plusDisLikeCount(menu: "Menu")
                    case meal.mealType[1]:
                        plusDisLikeCount(menu: "Menu2")
                    case meal.mealType[2]:
                        plusDisLikeCount(menu: "Menu3")
                    case meal.mealType[3]:
                        plusDisLikeCount(menu: "Menu4")
                    default:
                        break
                    }
                    
                    // 버튼 탭 히스토리에 저장 (dislike 생성)
                    buttonTapHistory["dislikeButtonTapped"] = true
                    UserDefaults.standard.set(buttonTapHistory, forKey: buttonTapHistoryKey)
                    
                    
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

















