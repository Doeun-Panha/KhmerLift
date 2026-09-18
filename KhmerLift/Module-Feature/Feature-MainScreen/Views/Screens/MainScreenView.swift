//
//  MainScreenView.swift
//  KhmerLift
//
//  Created by Panha on 17/9/26.
//

import SwiftUI

// ViewModel
@Observable
final class MainScreenViewModel {

}

// View
struct MainScreenView: View {
    @State private var viewModel = MainScreenViewModel()
    @State private var selectedTab: TabItem = .home
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Image("background")
                .resizable()
                .ignoresSafeArea()
                .containerRelativeFrame([.horizontal, .vertical])
            
            Group {
                switch selectedTab {
                case .home:
                    HomeScreenView()
                case .progress:
                    Text("Progress View")
                        .font(.nunito(24, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .more:
                    Text("More View")
                        .font(.nunito(24, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            GlassTabBarView(selectedTab: $selectedTab)
                .padding(.bottom, 10)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .dismissKeyboardOnTap()
    }
}

#Preview {
    MainScreenView()
}
