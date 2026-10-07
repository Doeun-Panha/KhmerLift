//
//  MainScreenView.swift
//  KhmerLift
//
//  Created by Panha on 17/9/26.
//

import SwiftUI

struct MainScreenView: View {
    @State private var viewModel = MainScreenViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("background")
                    .resizable()
                    .ignoresSafeArea(.all)
                
                VideoBackgroundView(name: viewModel.selectedBackgroundFileName, type: "mp4")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Group {
                        switch viewModel.selectedTab {
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
                        selectedTab: $viewModel.selectedTab,
                        onAddTapped: {
                            viewModel.handleAddTapped()
                        }
                    )
                    .padding(.bottom, 0)
                }
            }
            .dismissKeyboardOnTap()
        }
    }
}

#Preview {
    MainScreenView()
}
