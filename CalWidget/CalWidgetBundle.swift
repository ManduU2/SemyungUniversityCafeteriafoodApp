//
//  CalWidgetBundle.swift
//  CalWidget
//
//  Created by 김진혁 on 3/25/24.
//

import WidgetKit
import SwiftUI

@main
struct CalWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        
        SmallWidget()
        CalWidget()
        
        // 잠금화면 위젯버튼 창이 안나오면 핸드폰 전원을 끄고 시도해본다. -> iOS의 버그인듯.
        LockScreenWidget()
        LockScreenAccessoryRectangularWidget()
        
            
        
    }
    
}
