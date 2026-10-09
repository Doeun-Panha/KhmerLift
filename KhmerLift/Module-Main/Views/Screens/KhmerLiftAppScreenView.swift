//
//  KhmerLiftAppScreenView.swift
//  KhmerLift
//
//  Created by Panha on 16/9/26.
//

import SwiftUI
import SwiftData

@main
struct KhmerLiftAppScreenView: App {
    @State private var viewModel = KhmerLiftAppScreenViewModel()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch viewModel.lockState {
                case .checking:
                    ZStack {
                        Color.black.ignoresSafeArea()
                        ProgressView()
                            .tint(.white)
                    }
                    
                case .locked:
                    LockScreenView(viewModel: viewModel)
                    
                case .unlocked:
                    MainScreenView()
                }
            }
            .environment(viewModel)
            
            .task {
                await viewModel.checkAppLockOnLaunch()
            }
            
            .onChange(of: scenePhase) { _, newPhase in
                viewModel.handleScenePhaseChange(newPhase)
            }
        }
        .modelContainer(SwiftDataContainer.shared)
    }
}
