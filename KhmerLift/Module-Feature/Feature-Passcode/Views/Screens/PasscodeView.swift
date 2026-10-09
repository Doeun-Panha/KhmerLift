//
//  PasscodeSetupView.swift
//  KhmerLift
//
//  Created by Panha on 7/10/26.
//

import SwiftUI

struct PasscodeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: PasscodeViewModel
    
    @State private var deleteTapCount = 0
    @State private var shakeAttempts = 0
    @State private var isError = false
    @State private var isSuccess = false
    
    var onSuccess: (() -> Void)? = nil
    var onFailure: (() -> Void)? = nil
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 3)
    
    init(
        mode: PasscodeViewModel.Mode,
        onSuccess: (() -> Void)? = nil,
        onFailure: (() -> Void)? = nil
    ) {
        self._viewModel = State(initialValue: PasscodeViewModel(mode: mode))
        self.onSuccess = onSuccess
        self.onFailure = onFailure
    }
    
    var body: some View {
        VStack(spacing: 16) {
            headerView

            VStack(spacing: 30) {
                Spacer()
                
                Text(viewModel.titleText)
                    .font(.nunito(18, weight: .bold))
                    .foregroundStyle(.white)

                Spacer()
                
                HStack(spacing: 16) {
                    ForEach(0..<viewModel.pinLength, id: \.self) { index in
                        Circle()
                            .fill(
                                isSuccess
                                    ? Color.green
                                    : (isError
                                        ? Color.red
                                        : (index < viewModel.enteredPin.count ? Color.white : Color.white.opacity(0.2)))
                            )
                            .frame(width: 25, height: 25)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                            .scaleEffect(index < viewModel.enteredPin.count ? 1.1 : 1.0)
                            .animation(.spring(response: 0.2), value: viewModel.enteredPin.count)
                    }
                }
                .padding(.vertical, 10)
                .modifier(ShakeEffect(animatableData: CGFloat(shakeAttempts)))
                
                Spacer()
                
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(1...9, id: \.self) { num in
                        numpadButton(label: "\(num)") {
                            viewModel.appendDigit("\(num)")
                        }
                    }
                    
                    Spacer()
                    
                    numpadButton(label: "0") {
                        viewModel.appendDigit("0")
                    }
                    
                    Button(action: {
                        viewModel.deleteDigit()
                        deleteTapCount += 1
                    }) {
                        Image(systemName: "delete.left.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(width: 75, height: 75)
                            .symbolEffect(.bounce, value: deleteTapCount)
                            .contentShape(Circle())
                    }
                    .buttonStyle(BouncyButtonStyle())
                }
                .padding()
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
//            .overlay(
//                RoundedRectangle(cornerRadius: 32, style: .continuous)
//                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
//            )
//            .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
            .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .toolbar(.hidden, for: .navigationBar)
        
        .onChange(of: viewModel.isSuccess) { _, success in
            if success {
                triggerSuccessHaptic()
                
                withAnimation(.easeInOut(duration: 0.15)) {
                    isSuccess = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    onSuccess?()
                    dismiss()
                }
            }
        }
        .onChange(of: viewModel.errorTrigger) { _, _ in
//            triggerErrorHaptic()
            
            withAnimation(.easeInOut(duration: 0.1)) {
                isError = true
            }
            withAnimation(.linear(duration: 0.4)) {
                shakeAttempts += 1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isError = false
                }
            }
        }
        
        .toast(viewModel.toast)
        .appBackground()
    }
    
    private var headerView: some View {
        HStack(spacing: 12) {
            Button(action: {
                onFailure?()
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .glassEffect(.clear)

            Text("Passcode")
                .font(.nunito(22, weight: .bold))
                .foregroundStyle(.white)

            Spacer()

            Button(action: {
                onFailure?()
                dismiss()
            }) {
                Image("logo-icon")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
    }
    
    private func numpadButton(label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.nunito(24, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 75, height: 75)
                .background(Color.white.opacity(0.12))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.5), .white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(BouncyButtonStyle())
    }
}
