//
//  MainScreenView.swift
//  KhmerLift
//
//  Created by Panha on 17/9/26.
//

import SwiftUI

struct MainScreenView: View {
    @State private var selectedTab: TabItem = .progress
    @State private var showAddScreen = false
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                Image("background")
                    .resizable()
                    .ignoresSafeArea(.all)
                
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
                            showAddScreen = true
                        }
                    )
                    .padding(.bottom, 0)
                }
            }
            .dismissKeyboardOnTap()
            .navigationDestination(isPresented: $showAddScreen) {
                FaceIDScreenView(
                    timer: .constant(10),
                    status: .constant("Looking for face...")
                )
            }
        }
    }
}

#Preview {
    MainScreenView()
}
