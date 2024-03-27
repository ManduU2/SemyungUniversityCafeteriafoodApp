//
//  CalWidget.swift
//  CalWidget
//
//  Created by 김진혁 on 3/25/24.
//

import WidgetKit
import SwiftUI
import FirebaseFirestore
import FirebaseCore




let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd" // 원하는 날짜 포맷 설정
    return formatter
}()




struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(),currentDate: "" ,emoji: "", lunch: "", dinner: "")
    }
    
    
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        
        let db = Firestore.firestore()
        
        let currentDate = Date()
        let formattedDate = dateFormatter.string(from: currentDate)
        
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
                        
                        
                        
                        // here
                        // 데이터 저장
                        //                        if let sharedUserDefaults = UserDefaults(suiteName: "group.com.SemyungUniversityCafeteriafoodApp.ManduU2App") {
                        //                            sharedUserDefaults.set(breakfastMenu, forKey: "sharedDataKey")
                        //                        }
                        
                        
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
                        
                        
                        
                        // 데이터 저장
                        if let sharedUserDefaults = UserDefaults(suiteName: "group.com.SemyungUniversityCafeteriafoodApp.ManduU2App") {
                            sharedUserDefaults.set(lunchMenu, forKey: "sharedDataKey2")
                        }
                        
                        
                        
                        
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
                        
                        
                        
                        
                        // 데이터 저장
                        if let sharedUserDefaults = UserDefaults(suiteName: "group.com.SemyungUniversityCafeteriafoodApp.ManduU2App") {
                            sharedUserDefaults.set(dinnerMenu, forKey: "sharedDataKey3")
                        }
                        
                        
                        
                        
                        completion(dinnerMenu, nil)
                    } else {
                        completion(nil, nil)
                    }
                } else {
                    completion(nil, error)
                }
            }
        }
        
        
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
                    
                    
                    
                    let entry = SimpleEntry(date: Date(),currentDate: formattedDate ,emoji: breakfastMenu, lunch: lunchMenu, dinner: dinnerMenu)
                    completion(entry)
                }
            }
        }
    }
    
    
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        
        let db = Firestore.firestore()
        
        
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
                    
                    
                    
                    // 00시에만 실행되게 바꾸자 -> 작동은 문제 없는데 데이터베이스 과부화걸릴 가능성 있을듯
                    // 작은 화면은 시간마다 바꿀수 있게 해보자 -> 조식, 중식, 석식
                    // UI 쫌 더 수정해보자 -> 살짝 삐뚤삐둘하고 글자색, 배경색도 변경해야할뜻
                    
                    
                    // Generate a timeline consisting of five entries an hour apart, starting from the current date.
                    let currentDate = Date()
                    let formattedDate = dateFormatter.string(from: currentDate)
                    for _ in 0 ..< 5 {
                        //                        let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
                        let entry = SimpleEntry(date: currentDate, currentDate: formattedDate ,emoji: breakfastMenu, lunch: lunchMenu, dinner: dinnerMenu)
                        entries.append(entry)
                        
                    }
                    let timeline = Timeline(entries: entries, policy: .atEnd)
                    completion(timeline)
                    
                    
                    
                    /// 00시에 한 번 테스트
                    
                    // 다음날 00:00까지의 시간 계산
                    //                    let calendar = Calendar.current
                    //                    let currentDate = Date()
                    //                    let startOfNextDay = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: currentDate)!)
                    //                    let timeUntilMidnight = startOfNextDay.timeIntervalSince(currentDate)
                    //
                    //                    // 00:00에 업데이트 예약
                    //                    let midnight = currentDate.addingTimeInterval(timeUntilMidnight)
                    //                    let refreshDate = Calendar.current.date(byAdding: .minute, value: 1, to: midnight)!
                    //
                    //                    // 다음 날짜의 entry 생성
                    //                    let tomorrow = calendar.date(byAdding: .day, value: 1, to: currentDate)!
                    //                    let formattedDate = dateFormatter.string(from: tomorrow)
                    //                    let entry = SimpleEntry(date: midnight, currentDate: formattedDate, emoji: "", lunch: "", dinner: "")
                    //                    entries.append(entry)
                    //
                    //                    // 타임라인 생성
                    //                    let timeline = Timeline(entries: entries, policy: .after(refreshDate))
                    //                    completion(timeline)
                    
                    
                    
                    
                    
                    
                    
                    
                }
            }
        }
    }
    
}






struct SimpleEntry: TimelineEntry {
    var date: Date
    var currentDate: String
    let emoji: String
    let lunch: String
    let dinner: String
}



struct CalWidgetEntryView : View {
    // 위젯 크기 각각
    @Environment(\.widgetFamily) var family: WidgetFamily
    
    var entry: Provider.Entry
    
    var body: some View {
        sizeBody()
    }
    
    
    
    @ViewBuilder
    func sizeBody() -> some View {
        
        
        switch family {
            //                case .systemSmall:
            //                    VStack {
            //                        Text(entry.currentDate)
            //                            .font(.system(size: 12))
            //                            .foregroundColor(Color(hex: 0xc8d6e5))
            //
            //                        Divider()
            //                            .background(Color(hex: 0xc8d6e5))
            //
            //                        HStack {
            //                            HStack {
            //                                Text("중식 - ")
            //                                    .font(.system(size: 10))
            //                                    .foregroundColor(Color(hex: 0xc8d6e5))
            //
            //
            //                                Text(entry.lunch)
            //                                    .font(.system(size: 9))
            //                                    .foregroundColor(Color(hex: 0xc8d6e5))
            //
            //                            }
            //                        }
            //
            //                        Divider()
            //                            .background(Color(hex: 0xc8d6e5))
            //                    }
        case .systemMedium:
            VStack {
                Text(entry.currentDate)
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: 0xc8d6e5))
                Divider()
                    .background(Color(hex: 0xc8d6e5))
                HStack {
                    HStack {
                        Text("조식 - ")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: 0xc8d6e5))
                        
                        
                        Text(entry.emoji)
                            .font(.system(size: 8))
                            .foregroundColor(Color(hex: 0xc8d6e5))
                        
                    }
                    
                    
                    
                    
                    HStack {
                        Divider()
                            .background(Color(hex: 0xc8d6e5))
                        Text("중식 - ")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: 0xc8d6e5))
                        
                        
                        Text(entry.lunch)
                            .font(.system(size: 8))
                            .foregroundColor(Color(hex: 0xc8d6e5))
                        
                    }
                    
                    
                    
                    
                    HStack {
                        Divider()
                            .background(Color(hex: 0xc8d6e5))
                        Text("석식 - ")
                        
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: 0xc8d6e5))
                        
                        Text(entry.dinner)
                            .font(.system(size: 8))
                            .foregroundColor(Color(hex: 0xc8d6e5))
                        
                    }
                    
                }
                
                Divider()
                    .background(Color(hex: 0xc8d6e5))
            }
            

            
            // UI가 삐뚤했던 이유는 VStack에서 가운데 정렬로 되있어서 -> 왼쪽 정렬로 하면 성공 (보이지 않는 테두리를 생각해야함)
        case .systemLarge:
            
            Text(entry.currentDate)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: 0xc8d6e5))
            Divider()
                .background(Color(hex: 0xc8d6e5))
            
               
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                            .frame(width: 50)
                        Text("조식            -")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: 0xc8d6e5))
                        Spacer()
                            .frame(width: 20)
                        Text(entry.emoji)
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: 0xc8d6e5))
                    }
                    Divider()
                        .background(Color(hex: 0xc8d6e5))
                    HStack{
                        Spacer()
                            .frame(width: 50)
                        Text("중식            -")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: 0xc8d6e5))
                        Spacer()
                            .frame(width: 20)
                        Text(entry.lunch)
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: 0xc8d6e5))
                    }
                    Divider()
                        .background(Color(hex: 0xc8d6e5))
                    HStack{
                        Spacer()
                            .frame(width: 50)
                        Text("석식            -")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: 0xc8d6e5))
                        Spacer()
                            .frame(width: 20)
                        Text(entry.dinner)
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: 0xc8d6e5))
                    }
                }
            
            Divider()
                .background(Color(hex: 0xc8d6e5))
        default:
            EmptyView()
        }
        
        
    }
    
    
    
    
}





struct CalWidget: Widget {
    let kind: String = "CalWidget"
    
    init() {
        FirebaseApp.configure()
    }
    
    
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                CalWidgetEntryView(entry: entry)
                    .containerBackground(Color(hex: 0x222f3e), for: .widget) // 전체색 변경
            } else {
                CalWidgetEntryView(entry: entry)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)    // << here !! 전체색 변경
                    .background(Color(hex: 0x222f3e))
                
            }
        }
        .configurationDisplayName("세명대학교 학식 알리미")
        .description("홈 화면에서 오늘의 학식 메뉴를 전부 확인 할 수 있어요!")
        .supportedFamilies([.systemMedium, .systemLarge]) // 사이즈 지원
    }
}



///




// smallWidget
struct SmallWidgetView : View {
    var entry: Provider.Entry
    
    var body: some View {
        let components = Calendar.current.dateComponents([.hour, .minute], from: Date())
        let currentTime = components.hour! * 60 + components.minute!
        
        let isMorning = (0...659).contains(currentTime) // 아침 시간대: 0시부터 10시 59분까지
        let isLunchtime = (660...1019).contains(currentTime) // 점심 시간대: 11시부터 16시 59분까지
        let isDinnertime = (1020...1439).contains(currentTime) // 저녁 시간대: 17시부터 23시 59분까지
        
        var menuToShow = ""
        if isMorning {
            menuToShow = entry.emoji // 아침 메뉴
        } else if isLunchtime {
            menuToShow = entry.lunch // 점심 메뉴
        } else if isDinnertime {
            menuToShow = entry.dinner // 저녁 메뉴
        } else {
            menuToShow = "메뉴 없음" // 아침, 점심, 저녁 시간이 아닐 때
        }
        
        return VStack {
            Text(entry.currentDate)
                .font(.system(size: 12))
                .foregroundColor(Color(hex: 0xc8d6e5))
            
            Divider()
                .background(Color(hex: 0xc8d6e5))
            
            HStack {
                HStack {
                    if isMorning {
                        Text("조식 - ") // 아침 메뉴 표시
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: 0xc8d6e5))
                    } else if isLunchtime {
                        Text("중식 - ") // 점심 메뉴 표시
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: 0xc8d6e5))
                    } else if isDinnertime {
                        Text("석식 - ") // 저녁 메뉴 표시
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: 0xc8d6e5))
                    }
                    Text(menuToShow)
                        .font(.system(size: 9))
                        .foregroundColor(Color(hex: 0xc8d6e5))
                }
            }
            
            Divider()
                .background(Color(hex: 0xc8d6e5))
        }
    }
}





//@main
struct SmallWidget: Widget {
    let kind: String = "SmallWidget"
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                SmallWidgetView(entry: entry)
                    .containerBackground(Color(hex: 0x222f3e), for: .widget) // 전체색 변경
            } else {
                SmallWidgetView(entry: entry)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)    // << here !! 전체색 변경
                    .background(Color(hex: 0x222f3e))
                
            }
        }
        .configurationDisplayName("세명대학교 학식 알리미")
        .description("식사시간에 맞춰 학식 메뉴가 변경돼요!")
        .supportedFamilies([.systemSmall])
    }
}





//#Preview(as: .systemSmall) {
//    CalWidget()
//} timeline: {
//    SimpleEntry(date: .now, emoji: "😀")
//    SimpleEntry(date: .now, emoji: "🤩")
//}



extension Color {
    init(hex: Int, opacity: Double = 1.0) {
        let red = Double((hex >> 16) & 0xff) / 255
        let green = Double((hex >> 8) & 0xff) / 255
        let blue = Double((hex >> 0) & 0xff) / 255
        
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

