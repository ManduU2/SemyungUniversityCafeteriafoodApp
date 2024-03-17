//
//  CommentViewController.swift
//  WebCrawlingProject
//
//  Created by 김진혁 on 3/13/24.
//

import UIKit
import FirebaseCore
import FirebaseFirestore

class CommentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let db = Firestore.firestore()
    
    var tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    var commentTextField = UITextField()
    
    var sendButton = UIButton() // 화살표 모양 버튼
    
   
    
    
    
    // 댓글을 저장할 배열
    var comments: [String] = []
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        view.backgroundColor = .systemGray2
        
        
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        

        
        
        // 네비게이션 바 생성
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)) // 네비게이션 바의 기본 높이는 44입니다.
        
        // 네비게이션 바 아이템 생성
        let navItem = UINavigationItem(title: ViewController.navTitle + " 댓글 ") // 타이틀 설정
        
        // 네비게이션 바에 아이템 추가
        navigationBar.setItems([navItem], animated: false)
        
        // 뷰에 네비게이션 바 추가
        view.addSubview(navigationBar)
        
        
        
        // 화면의 절반만 나타남
        if let sheetPresentationController = sheetPresentationController {
            sheetPresentationController.detents = [.medium()]
            
        }
        
        
        applyConstraints()
        setupCommentTextField()
        setupSendButton() // 화살표 모양 버튼 설정
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchComments()
    }
    
    fileprivate func applyConstraints() {
       
        self.view.addSubview(self.tableView)
        tableView.backgroundColor = .red
        
      
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 44),
            self.tableView.heightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.8), // 화면의 절반 크기로 설정
            self.tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        
        
    }
    
    // 1. 댓글 데이터 불러오기
    func fetchComments() {
        let docRef = db.collection("Comment1").document("2024-03-14")
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let comment = document.data()?["댓글"] as? String {
                    self.comments.append(comment)
                    
                    // 테이블 뷰 리로드
                    self.tableView.reloadData()
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func setupCommentTextField() {
         commentTextField.placeholder = "댓글을 입력하세요"
         commentTextField.borderStyle = .roundedRect
         commentTextField.backgroundColor = .white
         commentTextField.translatesAutoresizingMaskIntoConstraints = false
         view.addSubview(commentTextField)

        NSLayoutConstraint.activate([
            commentTextField.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 0), // 테이블 뷰 아래에 8포인트 간격 추가
            commentTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            commentTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            commentTextField.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0) // 뷰의 safe area 바닥에서 8포인트 간격을 두고 배치
        ])
     }
    
    func setupSendButton() {
         // 화살표 모양 이미지 설정
         let sendImage = UIImage(systemName: "arrow.right.circle.fill")
         sendButton.setImage(sendImage, for: .normal)
         sendButton.tintColor = .systemBlue
         sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside) // 버튼 탭 액션 추가
         sendButton.translatesAutoresizingMaskIntoConstraints = false
         view.addSubview(sendButton)
         
         NSLayoutConstraint.activate([
             sendButton.centerYAnchor.constraint(equalTo: commentTextField.centerYAnchor), // 세로 중앙 정렬
             sendButton.trailingAnchor.constraint(equalTo: commentTextField.trailingAnchor, constant: -8), // 텍스트필드 오른쪽으로부터 간격 추가
             sendButton.widthAnchor.constraint(equalToConstant: 40), // 고정된 너비
             sendButton.heightAnchor.constraint(equalTo: sendButton.widthAnchor) // 정사각형 모양으로 유지
         ])
     }
    
    
    // 3. 댓글 데이터 저장
    @objc func sendButtonTapped() {
        guard let commentText = commentTextField.text, !commentText.isEmpty else {
            return
        }
        
        if ViewController.navTitle == "식단표 (학생회관_학생식당)" {
            db.collection("Comment1").document("2024-03-14").setData(["댓글": commentText], merge: true)
            
            // 댓글 저장 후 다시 불러오기
            fetchComments()
            
            // 입력 필드 초기화
            commentTextField.text = ""
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: .none)
        
        
        // 파이어베이스 [데이터 불러오기]
        
        if ViewController.navTitle == "식단표 (학생회관_학생식당)" {
            
            
            
            cell.textLabel?.text = comments[indexPath.row]
            
            
        }
        return cell
        
    }
    
    
    
}
