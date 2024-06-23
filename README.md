# 세명대학교 학식 알리미 앱

세명대학교 학식 메뉴를 간편하게 확인하고 알림을 받을 수 있는 어플리케이션 앱 입니다. (1인 개발)


iOS 다운로드 링크 : https://apps.apple.com/app/세명대학교-학식-알리미/id6479690864


Android 다운로드 링크 : https://play.google.com/store/apps/details?id=com.SemyungUniversityCafeteriafoodApp.ManduU2App

---


## 개발 계기

학식 메뉴를 확인할 수 있는 앱이 존재는 하지만, 그 앱 안에서 개별적으로 따로 메뉴를 확인하러 가야하고, 또 주간 단위로 학식 메뉴가 나오기 때문에 메뉴를 한눈에 보기 어려웠습니다.


그래서 이러한 단점을 보완하고, 추가로 몇가지 기능을 넣어 앱을 완성하면 좋을꺼 같아서 개발을 시작하게 되었습니다.


[앱의 기능]

- 학교 식당 메뉴를 확인할 수 있습니다.

- 배식시간에 맞춰 알림을 받으실 수 있습니다.

- 좋아요, 싫어요 기능을 이용하실 수 있습니다.

- 홈화면, 잠금화면 위젯을 식당 메뉴으로 식당 메뉴를 확인할 수 있습니다.



---


## 사용 플랫폼

[ Firebase ]

- FireStore Database
  
- FCM

## 사용 언어 및 라이브러리
[ Python ] Selenium 자동화 웹 크롤링 사용
- 추후 예정 

[ Java ] Android Studio 에서 사용
- 추후 예정

[ Swift ]
- UIKit
  
- SwiftUI
  
- FSCalendar
  
- WidgetKit


---

## 시스템 아키텍처 설계
1. 세명대학교 포탈 시스템에 매주 업데이트 되는 식단표를 **Selenium을 통해 크롤링하고 csv파일로 만듭니다.**
2. 만들어진 csv파일을 Firestore Database 삽입합니다.
3. 구조가 맞춰진 앱은 해당하는 날짜의 식단 메뉴를 보여줍니다.


