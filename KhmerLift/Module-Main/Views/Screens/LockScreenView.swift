//
//  LockScreenView.swift
//  KhmerLift
//
//  Created by Panha on 6/10/26.
//

import SwiftUI

struct LockScreenView: View {
    @Bindable var viewModel: KhmerLiftAppScreenViewModel
    
    var body: some View {
        containerView
    }
}

extension LockScreenView {
    private var containerView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 20) {
                Image(systemName: "lock")
                    .font(.system(size: 70))
                    .foregroundStyle(.white)
                    .padding(.top, 50)
                
                VStack(spacing: 8) {
                    Text("KhmerLift Locked")
                        .font(.nunito(22, weight: .bold))
                        .foregroundStyle(.white)
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                }
            }
            .padding()
            .padding(.bottom, 50)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            
            Spacer()
            
            VStack(spacing: 16) {
                if viewModel.isFaceIDEnabled {
                    Button {
                        Task {
                            await viewModel.authenticateWithFaceID()
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "faceid")
                                .font(.title3)
                            Text("Unlock with Face ID")
                        }
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.cyan)
                        .clipShape(Capsule())
                    }
                    .glassEffect(.clear, in: Capsule())
                }
                
                if viewModel.isPasscodeEnabled {
                    Button {
                        viewModel.showPasscodeSheet = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "number.square")
                                .font(.title3)
                            
                            Text("Unlock with Passcode")
                        }
                        .font(.headline)
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            viewModel.isFaceIDEnabled
                                ? .clear
                                : Color.blue.opacity(0.15)
                        )
                        .clipShape(Capsule())
                    }
                    .glassEffect(.clear, in: Capsule())
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .appBackground()
        
        .fullScreenCover(isPresented: $viewModel.showPasscodeSheet) {
            PasscodeView(mode: .unlock) {
                    viewModel.unlockApp()
            } onFailure: {
                viewModel.showPasscodeSheet = false
            }
        }
    }
}
