//
//  FSCalendarExtension.swift
//  WebCrawlingProject
//
//  Created by 김진혁 on 4/5/24.
//

import Foundation
import FSCalendar


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
