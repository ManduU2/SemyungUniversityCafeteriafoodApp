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


// 위젯 타이틀에 사용될 날짜 포맷팅
let titleDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR") // 한국어 버전
    formatter.dateFormat = "M월 d일 (EEEEE)" // 원하는 날짜 포맷 설정
    return formatter
}()


// 데이터베이스 가져올때 사용되는 날짜 포맷팅
let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd" // 원하는 날짜 포맷 설정
    return formatter
}()




struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(),currentDate: "", titleCurrentDate: "" ,emoji: "", lunch: "", dinner: "")
    }
    
    
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        
        let db = Firestore.firestore()
        
        let currentDate = Date()
        let formattedDate = dateFormatter.string(from: currentDate)
        let titleFormattedDate = titleDateFormatter.string(from: currentDate)
        
        
        
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
                    
                    
                    
                    let entry = SimpleEntry(date: Date(), currentDate: formattedDate, titleCurrentDate: titleFormattedDate, emoji: breakfastMenu, lunch: lunchMenu, dinner: dinnerMenu)
                    completion(entry)
                }
            }
        }
    }
    
    
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        
        let db = Firestore.firestore()
        
        let currentDate = Date()
        let formattedDate = dateFormatter.string(from: currentDate)
        let titleFormattdeDate = titleDateFormatter.string(from:currentDate)
        
        
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
                    // 작은 화면은 시간마다 바꿀수 있게 해보자 -> 조식, 중식, 석식 (완료)
                    // UI 쫌 더 수정해보자 -> 살짝 삐뚤삐둘하고 글자색, 배경색도 변경해야할뜻 (완료)
                    
                    
                    // Generate a timeline consisting of five entries an hour apart, starting from the current date.

                    
                    
                    for _ in 0 ..< 5 {
                        //                        let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
                        let entry = SimpleEntry(date: currentDate, currentDate: formattedDate, titleCurrentDate: titleFormattdeDate,emoji: breakfastMenu, lunch: lunchMenu, dinner: dinnerMenu)
                        entries.append(entry)
                        
                    }
                    
                    // .atEnd 수정 해야할뜻.
                    let timeline = Timeline(entries: entries, policy: .atEnd)
                    completion(timeline)
                    
                }
            }
        }
    }
    
}



struct SimpleEntry: TimelineEntry {
    var date: Date
    var currentDate: String
    var titleCurrentDate: String
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
        
        
        let cleanEmojiBreak = entry.emoji.replacingOccurrences(of: "\n", with: "\n• ")
        let cleanEmojiLunch = entry.lunch.replacingOccurrences(of: "\n", with: "\n• ")
        let cleanEmojidinner = entry.dinner.replacingOccurrences(of: "\n", with: "\n• ")
        
            switch family {
                
            case .systemMedium:
                VStack () {
                    Text(entry.titleCurrentDate)
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: 0xc8d6e5))
                        .fontWeight(.bold)
                    Divider()
                        .background(Color(hex: 0xc8d6e5))
                    HStack() {
                        HStack {
                            Text("조식")
                                .font(.system(size: 11))
                                .foregroundColor(Color(hex: 0xc8d6e5))
                                .fontWeight(.bold)
                                                    }
                        .frame(maxWidth: .infinity) // 각 HStack을 동일한 크기로 만듭니다.
                        Divider()
                            .background(Color(hex: 0xc8d6e5))
                            .frame(height: 18) // Divider의 높이를 설정
                        HStack {
                            Text("중식")
                                .font(.system(size: 11))
                                .foregroundColor(Color(hex: 0xc8d6e5))
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity) // 각 HStack을 동일한 크기로 만듭니다.
                        Divider()
                            .background(Color(hex: 0xc8d6e5))
                            .frame(height: 18) // Divider의 높이를 설정
                        HStack {
                            Text("석식")
                                .font(.system(size: 11))
                                .foregroundColor(Color(hex: 0xc8d6e5))
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity) // 각 HStack을 동일한 크기로 만듭니다.
                    }
                    Divider()
                        .background(Color(hex: 0xc8d6e5))
                    HStack(alignment: .top) {
                        
                        HStack {
                            Text("• " + cleanEmojiBreak)
                                .font(.system(size: 8))
                                .foregroundColor(Color(hex: 0xc8d6e5))
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading) // 각 HStack을 동일한 크기로 만듭니다.
                        Divider()
                            .background(Color(hex: 0xc8d6e5))
                        
                        HStack {
                            Text("• " + cleanEmojiLunch)
                                .font(.system(size: 8))
                                .foregroundColor(Color(hex: 0xc8d6e5))
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading) // 각 HStack을 동일한 크기로 만듭니다.
                        
                        Divider()
                            .background(Color(hex: 0xc8d6e5))
                        HStack {

                            
                            Text("• " + cleanEmojidinner)
                                .font(.system(size: 8))
                                .foregroundColor(Color(hex: 0xc8d6e5))
                                .fontWeight(.bold)
                            
                        }
                        .frame(maxWidth: .infinity, alignment: .leading) // 각 HStack을 동일한 크기로 만듭니다.
                        
                    }
                    Divider()
                        .background(Color(hex: 0xc8d6e5))
                }
                // UI가 삐뚤했던 이유는 VStack에서 가운데 정렬로 되있어서 -> 왼쪽 정렬로 하면 성공 (보이지 않는 테두리를 생각해야함)
            case .systemLarge:
                VStack(alignment: .center) {
                    
                    Text(entry.titleCurrentDate)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: 0xc8d6e5))
                        .fontWeight(.bold)
                    VStack(alignment: .leading) {
                        Divider()
                            .background(Color(hex: 0xc8d6e5))
                        HStack {
                            Spacer()
                                .frame(width: 50)
                            Text("조식            -    ")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: 0xc8d6e5))
                                .fontWeight(.bold)
                            Spacer()
                                .frame(width: 20)
                            Text("• " + cleanEmojiBreak)
                                .font(.system(size: 11))
                                .foregroundColor(Color(hex: 0xc8d6e5))
                                .fontWeight(.bold)
                        }
                        Divider()
                            .background(Color(hex: 0xc8d6e5))
                        HStack{
                            Spacer()
                                .frame(width: 50)
                            Text("중식            -    ")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: 0xc8d6e5))
                                .fontWeight(.bold)
                            Spacer()
                                .frame(width: 20)
                            Text("• " + cleanEmojiLunch)
                                .font(.system(size: 11))
                                .foregroundColor(Color(hex: 0xc8d6e5))
                                .fontWeight(.bold)
                        }
                        Divider()
                            .background(Color(hex: 0xc8d6e5))
                        HStack{
                            Spacer()
                                .frame(width: 50)
                            Text("석식            -    ")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: 0xc8d6e5))
                                .fontWeight(.bold)
                            Spacer()
                                .frame(width: 20)
                            Text("• " + cleanEmojidinner)
                                .font(.system(size: 11))
                                .foregroundColor(Color(hex: 0xc8d6e5))
                                .fontWeight(.bold)
                        }
                        Divider()
                            .background(Color(hex: 0xc8d6e5))
                        
                    }
                }
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
    
    
    // 1. 일단 위젯을 분리해야함 -> 디스크립션이 겹침
    // 2. UI를 수정해야함 -> 크기에 맞게
    // 3. 에뮬레이터에서는 실행이 잘 되는데, 실 기기에서는 잘 안됨 -> 잘 한번 해보자
    private let supportedFamilies:[WidgetFamily] = {
            if #available(iOSApplicationExtension 16.0, *) {
                return [.systemMedium, .systemLarge, .accessoryCircular, .accessoryRectangular]
            } else {
                return [.systemMedium, .systemLarge]
            }
        }()
    
    // iOS 17버전에는 .containerBackground을 추가로 contentMargin 색을 채울 수 있음.
    // 17 이하는 ZStack 으로 묶어 contentMargin을 채움.
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                CalWidgetEntryView(entry: entry)
                    .containerBackground(Color(hex: 0x222f3e), for: .widget) // 전체색 변경
                    
            } else {
                ZStack {
                    Color(hex: 0x222f3e) // Set background color
                    CalWidgetEntryView(entry: entry)
                }
            }
           
        }
        
        
        .configurationDisplayName("세명대학교 학식 알리미")
        .description("홈 화면에서 오늘의 학식 메뉴를 전부 확인 할 수 있어요!")
        .supportedFamilies([.systemMedium, .systemLarge]) // 사이즈 지원
    }
}







// smallWidget
struct SmallWidgetView : View {
    var entry: Provider.Entry
    
    var body: some View {
        let components = Calendar.current.dateComponents([.hour, .minute], from: Date())
        let currentTime = components.hour! * 60 + components.minute!
        
        let isMorning = (0...599).contains(currentTime) // 아침 시간대: 0시부터 9시 59분까지
        let isLunchtime = (600...899).contains(currentTime) // 점심 시간대: 10시부터 14시 59분까지
        let isDinnertime = (900...1439).contains(currentTime) // 저녁 시간대: 15시부터 23시 59분까지
        
        let dotBreak = entry.emoji.replacingOccurrences(of: "\n", with: "\n• ")
        let dotLunch = entry.lunch.replacingOccurrences(of: "\n", with: "\n• ")
        let dotDinner = entry.dinner.replacingOccurrences(of: "\n", with: "\n• ")
        
        
        
        var menuToShow = ""
        if isMorning {
            menuToShow = dotBreak // 아침 메뉴
        } else if isLunchtime {
            menuToShow = dotLunch // 점심 메뉴
        } else if isDinnertime {
            menuToShow = dotDinner // 저녁 메뉴
        } else {
            menuToShow = "메뉴 없음" // 아침, 점심, 저녁 시간이 아닐 때
        }
        
        
        
        
        return VStack(alignment: .leading) {
            
            VStack(alignment: .leading){
            if isMorning {
                Text(entry.titleCurrentDate + "     < 조식 >")
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: 0xc8d6e5))
                    .fontWeight(.bold)
            } else if isLunchtime {
                Text(entry.titleCurrentDate + "     < 중식 >")
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: 0xc8d6e5))
                    .fontWeight(.bold)
            } else if isDinnertime {
                Text(entry.titleCurrentDate + "     < 석식 >")
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: 0xc8d6e5))
                    .fontWeight(.bold)
            }
        }
            
                
            
            Divider()
                .background(Color(hex: 0xc8d6e5))
            
            HStack {
                
                VStack(alignment: .leading){
                    Text("• " + menuToShow)
                        .font(.system(size: 9))
                        .foregroundColor(Color(hex: 0xc8d6e5))
                        .fontWeight(.bold)
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
        } //00시 ~ 10 || 10 ~ 15 || 15 ~ 00
        .configurationDisplayName("세명대학교 학식 알리미")
        .description("식사시간에 맞춰 학식 메뉴를 확인할 수 있어요!")
        .supportedFamilies([.systemSmall])
    }
}






struct LockScreenWidget: Widget {
    let kind: String = "LockScreenWidget"
    
    init() {
        FirebaseApp.configure()
    }
    
    private let supportedFamilies:[WidgetFamily] = {
            if #available(iOSApplicationExtension 16.0, *) {
                return [.accessoryCircular]
            } else {
                return []
            }
        }()
    
    
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                LockScreenWidgetView(entry: entry)
                    .containerBackground(Color(hex: 0x222f3e), for: .widget) // 전체색 변경
            } else {
                LockScreenWidgetView(entry: entry)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)    // << here !! 전체색 변경
                    .background(Color(hex: 0x222f3e))
                
            }
        }
        .configurationDisplayName("세명대학교 학식 알리미")
        .description("세명대학교 학식 알리미를 실행해요!")
        .supportedFamilies(supportedFamilies)
    }
    
    
}


struct LockScreenWidgetView: View {
    // 위젯 크기 각각
    @Environment(\.widgetFamily) var family: WidgetFamily
    
    var entry: Provider.Entry
    
    
    var body: some View {
        sizeBody()
    }
    
    
    
    
    
    @ViewBuilder
    func sizeBody() -> some View {
        
        if #available(iOSApplicationExtension 16.0, *) {
            switch family {
            
            case .accessoryCircular:
                ZStack {
                        Circle()
                        .fill(Color.black.opacity(1.0)) // 원의 배경색 설정 / 원의 투명도 설정
                            .frame(width: 58, height: 58) // 원의 크기 조정
                        Image("meal(white2)")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40) // 이미지 크기 조정
                    }
            default:
                EmptyView()
            }
        }
        
        else {
            EmptyView()
        }
        
    }
    
    
    
    
}






struct LockScreenAccessoryRectangularWidget: Widget {
    let kind: String = "LockScreenAccessoryRectangularWidget"
    
    init() {
        FirebaseApp.configure()
    }
    
    private let supportedFamilies:[WidgetFamily] = {
            if #available(iOSApplicationExtension 16.0, *) {
                return [.accessoryRectangular]
            } else {
                return []
            }
        }()
    
    
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                LockScreenAccessoryRectangularView(entry: entry)
                    .containerBackground(Color(hex: 0x222f3e), for: .widget) // 전체색 변경
            } else {
                LockScreenAccessoryRectangularView(entry: entry)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)    // << here !! 전체색 변경
                    .background(Color(hex: 0x222f3e))
                
            }
        }
        .configurationDisplayName("세명대학교 학식 알리미")
        .description("식사시간에 맞춰 학식 메뉴를 확인할 수 있어요!")
        .supportedFamilies(supportedFamilies)
    }
    
    
}


struct LockScreenAccessoryRectangularView: View {
    
    var entry: Provider.Entry
    
    var body: some View {
        let components = Calendar.current.dateComponents([.hour, .minute], from: Date())
        let currentTime = components.hour! * 60 + components.minute!
        
        let isMorning = (0...599).contains(currentTime) // 아침 시간대: 0시부터 9시 59분까지
        let isLunchtime = (600...899).contains(currentTime) // 점심 시간대: 10시부터 14시 59분까지
        let isDinnertime = (900...1439).contains(currentTime) // 저녁 시간대: 15시부터 23시 59분까지
        
        var menuToShow = ""
        
        // 줄바꿈 제거
        let cleanEmojiBreak = entry.emoji.replacingOccurrences(of: "\n", with: ",")
        let cleanEmojiLunch = entry.lunch.replacingOccurrences(of: "\n", with: ",")
        let cleanEmojiDinner = entry.dinner.replacingOccurrences(of: "\n", with: ",")
        
        
        
        if isMorning {
            menuToShow = cleanEmojiBreak // 아침 메뉴
        } else if isLunchtime {
            menuToShow = cleanEmojiLunch // 점심 메뉴
        } else if isDinnertime {
            menuToShow = cleanEmojiDinner // 저녁 메뉴
        } else {
            menuToShow = "메뉴 없음" // 아침, 점심, 저녁 시간이 아닐 때
        }
        

        
        
        
        return GeometryReader { geometry in
            
                    HStack {
                        HStack {
                            if isMorning {
                                Text("조식 - ") // 아침 메뉴 표시
                                    .font(.system(size: 14))
                                    
                                    .fontWeight(.black)
                            } else if isLunchtime {
                                Text("중식 - ") // 점심 메뉴 표시
                                    .font(.system(size: 14))
                                    
                                    .fontWeight(.black)
                            } else if isDinnertime {
                                Text("석식 - ") // 저녁 메뉴 표시
                                    .font(.system(size: 14))
                                    
                                    .fontWeight(.black)
                            }
                            Text(menuToShow)
                                .font(.system(size: 10))

                                .fontWeight(.heavy)
                        }
                    }
                
                .frame(width: geometry.size.width, height: geometry.size.height) // 전체 화면 크기로 설정
                
            
        }
    }
        
    }
    
    
    
    




extension Color {
    init(hex: Int, opacity: Double = 1.0) {
        let red = Double((hex >> 16) & 0xff) / 255
        let green = Double((hex >> 8) & 0xff) / 255
        let blue = Double((hex >> 0) & 0xff) / 255
        
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

