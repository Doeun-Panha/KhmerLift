//
//  MainScreenView.swift
//  KhmerLift
//
//  Created by Panha on 17/9/26.
//

import SwiftUI

struct MainScreenView: View {
    @State private var selectedTab: TabItem = .home
    @State private var showAddScreen = false
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                Image("background")
                    .resizable()
                    .ignoresSafeArea(.all)
                
                VideoBackgroundView(name: "bike-video", type: "mp4")
                                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Group {
                        switch selectedTab {
                        case .home:
                            HomeScreenView()
                            
                        case .progress:
                            ProgressScreenView()
                            
                        case .more:
                            MoreScreenView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    GlassTabBarView(
                        selectedTab: $selectedTab,
                        onAddTapped: {
                            dismissKeyboard()
                            showAddScreen = true
                        }
                    )
                    .padding(.bottom, 0)
                }
            }
            .dismissKeyboardOnTap()
            .onChange(of: selectedTab) { _, _ in
                dismissKeyboard()
            }
        }
    }
}

#Preview {
    MainScreenView()
}
