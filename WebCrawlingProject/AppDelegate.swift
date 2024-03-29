//
//  AppDelegate.swift
//  WebCrawlingProject
//
//  Created by 김진혁 on 3/4/24.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseFirestore

// Notifications
import UserNotifications




@main
class AppDelegate: UIResponder, UIApplicationDelegate{
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 아침메뉴 가져오기
        FirebaseApp.configure()
        let db = Firestore.firestore()
        
        
        // 알림 권한 요청
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                print("사용자가 알림 권한을 허용했습니다.")
            } else {
                print("사용자가 알림 권한을 거부했습니다.")
            }
        }
    
        
        UNUserNotificationCenter.current().delegate = self
        
        
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
        
        
        // 아침메뉴 가져오기
        getBreakfastMenu { (breakfastMenu, error) in
            guard let breakfastMenu = breakfastMenu else {
                print("Error getting breakfast menu: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // 점심메뉴 가져오기
            getLunchMenu { (lunchMenu, error) in
                guard let lunchMenu = lunchMenu else {
                    print("Error getting lunch menu: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                // 저녁메뉴 가져오기
                getDinnerMenu { (dinnerMenu, error) in
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
        

        
        return true
    }
    
    
    
 
    
    
    
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
        
        
        
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        
        let container = NSPersistentContainer(name: "WebCrawlingProject")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                
                
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                
                
                
                
                
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    
    // 포그라운드 식단 알림 설정
    //    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    //            // 앱이 foreground에 있을 때 알림을 표시하기 위한 설정
    //            completionHandler([.alert, .sound])
    //        }
    
}


extension AppDelegate: UNUserNotificationCenterDelegate {
    // 앱이 실행 중일 때 알림을 처리하기 위한 메서드
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
    
    // 사용자가 알림을 탭하여 앱을 열 때 실행되는 메서드
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // 알림을 처리하는 추가 작업이 필요한 경우 이곳에 작성
        completionHandler()
    }
}










