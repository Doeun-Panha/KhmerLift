//
//  MoreScreenView.swift
//  KhmerLift
//
//  Created by Panha on 25/9/26.
//

import SwiftUI

struct MoreScreenView: View {
    @Environment(KhmerLiftAppScreenViewModel.self) private var appViewModel
    @State private var viewModel = MoreScreenViewModel()
    
    var body: some View {
        containerView
    }
}

extension MoreScreenView {
    private var containerView: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 16) {
                HStack(spacing: 5) {
                    Text("Settings")
                        .font(.nunito(26, weight: .heavy))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        appViewModel.lockApp()
                        triggerWarningHaptic()
                    }) {
                        Image(systemName: "lock")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())
                            .contentShape(Circle())
                    }
                    .buttonStyle(BouncyButtonStyle())
                    .glassEffect(.clear)
                    .disabled(!appViewModel.isLockEnabled)
                    .opacity(appViewModel.isLockEnabled ? 1.0 : 0.5)
                }
                .padding(.top, 30)
                
                ScrollView {
                    VStack(spacing: 16) {
                        GlassSwitchButtonView(
                            title: "Security",
                            name: "Face ID",
                            isOn: Binding(
                                get: { viewModel.enableFaceID },
                                set: { viewModel.handleFaceIDToggleChange($0) }
                            )
                        )
                        
//                        GlassAccessoryButtonView(
//                            name: "My Face",
//                            assessory: "chevron.right"
//                        ) {
//
//                        }
                        
                        GlassSwitchButtonView(
                            name: "Passcode",
                            isOn: Binding(
                                get: { viewModel.enablePasscode },
                                set: { viewModel.handlePasscodeToggleChange($0) }
                            )
                        )
                        
                        GlassDropdownView(
                            title: "Background",
                            placeholder: "Select Background",
                            selection: $viewModel.selectedBackground,
                            items: viewModel.availableBackgrounds,
                            onAddNew: {
                                viewModel.isAddingBackground = true
                            }
                        )
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.leading, 10)
            
            .navigationDestination(
                isPresented: $viewModel.navigateToFaceIDSetup,
            ) {
                FaceIDScreenView(
                    onSuccess: {
                        viewModel.confirmFaceIDSetupSuccess()
                    },
                    onFailure: {
                        viewModel.handleFaceIDDismissal()
                    }
                )
            }
            .navigationDestination(
                isPresented: $viewModel.navigateToFaceIDDisable,
            ) {
                PasscodeView(mode: .unlock) {
                    viewModel.confirmFaceIDDisableSuccess()
                } onFailure: {
                    viewModel.handleFaceIDDisableDismissal()
                }
            }
            .navigationDestination(
                isPresented: $viewModel.navigateToPasscodeSetup,
            ) {
                PasscodeView(mode: .setup) {
                    viewModel.confirmPasscodeSetupSuccess()
                } onFailure: {
                    viewModel.handlePasscodeDismissal()
                }
            }
            .navigationDestination(
                isPresented: $viewModel.navigateToPasscodeDisable,
            ) {
                PasscodeView(mode: .unlock) {
                    viewModel.confirmPasscodeDisableSuccess()
                } onFailure: {
                    viewModel.handlePasscodeDisableDismissal()
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
}

#Preview {
    MoreScreenView()
}
