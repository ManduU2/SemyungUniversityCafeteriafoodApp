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
        
    }
}
