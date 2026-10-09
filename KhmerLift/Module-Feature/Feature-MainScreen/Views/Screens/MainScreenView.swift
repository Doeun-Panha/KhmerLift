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
            .dismissKeyboardOnTap()
            .appBackground()
        }
    }
}

#Preview {
    MainScreenView()
        .environment(KhmerLiftAppScreenViewModel())
}
