//
//  AppBackgroundModifier.swift
//  KhmerLift
//
//  Created by Panha on 8/10/26.
//

import SwiftUI

struct AppBackgroundModifier: ViewModifier {
    @AppStorage("selectedBackgroundFileName") private var backgroundFileName: String = "bike-video"
    @AppStorage("selectedBackgroundFileType") private var backgroundFileType: String = "mp4"

    func body(content: Content) -> some View {
        ZStack {
            Image("background")
                .resizable()
                .ignoresSafeArea()
            
            VideoBackgroundView(name: backgroundFileName, type: backgroundFileType)
                .ignoresSafeArea()
            
            content
        }
    }
}
