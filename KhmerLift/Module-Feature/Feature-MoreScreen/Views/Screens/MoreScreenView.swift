//
//  MoreScreenView.swift
//  KhmerLift
//
//  Created by Panha on 25/9/26.
//

import SwiftUI

struct MoreScreenView: View {
    @State private var viewModel = MoreScreenViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 16) {
                HStack(spacing: 5) {
                    Text("Settings")
                        .font(.nunito(26, weight: .heavy))
                        .foregroundStyle(.white)
                    
                    Spacer()
                }
                .padding(.top, 30)
                
                ScrollView {
                    VStack(spacing: 16) {
                        GlassSwitchButtonView(
                            title: "Security",
                            name: "Biometric Face ID",
                            isOn: Binding(
                                get: { viewModel.enableFaceID },
                                set: { viewModel.handleFaceIDToggleChange($0) }
                            )
                        )
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.leading, 10)
            .navigationDestination(isPresented: $viewModel.navigateToFaceID) {
                FaceIDScreenView(
                    onSuccess: {
                        viewModel.confirmFaceIDSetupSuccess()
                    },
                    onFailure: {
                        viewModel.handleFaceIDToggleChange(false)
                    }
                )
                .onDisappear {
                    viewModel.handleFaceIDDismissal()
                }
            }
        }
        .alert("Face ID Not Set Up", isPresented: $viewModel.showSettingsAlert) {
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Face ID is not set up on this device. Go to 'Settings' > 'Face ID & Passcode' > 'Set Up Face ID' to set it up.")
        }
        .toast(viewModel.toast)
    }
}

#Preview {
    MoreScreenView()
}
