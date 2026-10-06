//
//  LockScreenView.swift
//  KhmerLift
//
//  Created by Panha on 6/10/26.
//

import SwiftUI

struct LockScreenView: View {
    var viewModel: KhmerLiftAppScreenViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "lock")
                .font(.system(size: 70))
                .foregroundStyle(.white)
            
            VStack(spacing: 8) {
                Text("KhmerLift Locked")
                    .font(.nunito(22, weight: .bold))
                    .foregroundStyle(.white)
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                }
            }
            
            Spacer()
            
            Button {
                Task {
                    await viewModel.authenticate()
                }
            } label: {
                HStack {
                    Image(systemName: "faceid")
                    Text("Unlock with Face ID")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .clipShape(Capsule())
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
    }
}
